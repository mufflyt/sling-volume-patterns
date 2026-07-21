# =============================================================================
# fit_volume_models.R
#
# Repeated-measures models of annual physician sling volume, replacing reliance
# on rank tests over non-independent provider-year rows. Produces:
#   output/tables/table_8_volume_gee.csv         Poisson GEE (cluster = NPI)
#   output/tables/table_8b_volume_gee_no2020.csv sensitivity excluding 2020
#   output/tables/table_9_per_physician.csv      one-value-per-physician (2ndary)
#   output/tables/table_8_volume_nb_mixed.csv    NB mixed model (if glmmTMB loads)
#
# Usage: Rscript scripts/fit_volume_models.R [puf_classified.rds]
# =============================================================================

suppressWarnings(suppressMessages(library(dplyr)))
source("R/reporting_stats_helpers.R")
source("R/analyze_sling_patterns.R")
source("R/volume_models.R")

args <- commandArgs(trailingOnly = TRUE)
puf_classified_path <- if (length(args) >= 1) args[[1]] else
  "/Volumes/MufflySamsung 1/sling-volume-patterns/data/cache/puf_classified.rds"
year_col <- "puf_year"

res <- analyze_midurethral_sling_patterns(
  medicare_puf_data    = readRDS(puf_classified_path),
  year_col             = year_col,
  abog_npi_csv         = "data/canonical_abog/canonical_abog_npi_LATEST.csv",
  urps_urology_npi_csv = "data/abu_urology/abu_urps_npi_LATEST.csv",
  exclude_years        = tryCatch(config::get("exclude_years"), error = function(e) NULL),
  verbose              = FALSE
)
pv <- res$provider_volume
dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)

fmt <- function(tbl) tbl |>
  mutate(across(c(rate_ratio, ci_low, ci_high), ~round(.x, 3)),
         `RR (95% CI)` = sprintf("%.2f (%.2f-%.2f)", rate_ratio, ci_low, ci_high)) |>
  select(term, `RR (95% CI)`, p_value = p_formatted)

# ── Primary: Poisson GEE, cluster = NPI ──────────────────────────────────────
gee <- fit_volume_gee(pv, year_col = year_col, reference_specialty = "URPS")
if (!is.null(gee)) {
  readr::write_csv(fmt(gee$terms), "output/tables/table_8_volume_gee.csv")
  cat("=== Table 8: Poisson GEE (ref = URPS, cluster = NPI) ===\n")
  print(as.data.frame(fmt(gee$terms)), row.names = FALSE)
}

# ── Sensitivity: exclude 2020 (COVID) ────────────────────────────────────────
gee_no2020 <- fit_volume_gee(pv, year_col = year_col,
                             reference_specialty = "URPS", exclude_2020 = TRUE)
if (!is.null(gee_no2020)) {
  readr::write_csv(fmt(gee_no2020$terms), "output/tables/table_8b_volume_gee_no2020.csv")
}

# ── NB mixed model (glmmTMB) — runs where OpenMP/TMB is available ─────────────
nb <- fit_volume_nb_mixed(pv, year_col = year_col, reference_specialty = "URPS")
if (!is.null(nb)) {
  readr::write_csv(fmt(nb$terms), "output/tables/table_8_volume_nb_mixed.csv")
  cat("\n=== NB mixed model (glmmTMB) ===\n")
  print(as.data.frame(fmt(nb$terms)), row.names = FALSE)
} else {
  cat("\n[NB mixed model skipped — glmmTMB not loadable in this environment]\n")
}

# ── Secondary: one value per physician ───────────────────────────────────────
pp_tests <- test_per_physician_volume(pv)
readr::write_csv(pp_tests, "output/tables/table_9_per_physician.csv")
pp <- per_physician_volume(pv)
cat("\n=== Table 9: per-physician median annual volume by specialty ===\n")
print(as.data.frame(pp |> group_by(specialty_group) |>
  summarise(n_physicians = n(),
            median_of_median = median(median_annual_volume),
            .groups = "drop") |> arrange(desc(median_of_median))), row.names = FALSE)
cat("\n-- tests (one obs per physician) --\n")
print(as.data.frame(pp_tests |> select(test, statistic, df, p_formatted)), row.names = FALSE)
