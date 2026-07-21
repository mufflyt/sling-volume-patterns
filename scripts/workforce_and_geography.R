# =============================================================================
# workforce_and_geography.R
#
# Manuscript points #5 (workforce entry/continuation/exit), #6 (specialty-
# specific market-share trends), and #7 (restrained state-level geography).
# Writes:
#   output/tables/table_11_workforce_dynamics.csv
#   output/tables/table_11b_entrants_by_specialty.csv
#   output/tables/table_12_specialty_share_trends.csv
#   output/tables/table_13_geography_by_state.csv
#
# Usage: Rscript scripts/workforce_and_geography.R [puf_classified.rds]
# =============================================================================

suppressWarnings(suppressMessages(library(dplyr)))
source("R/reporting_stats_helpers.R")
source("R/analyze_sling_patterns.R")
source("R/workforce_dynamics.R")

args <- commandArgs(trailingOnly = TRUE)
puf_classified_path <- if (length(args) >= 1) args[[1]] else
  "/Volumes/MufflySamsung 1/sling-volume-patterns/data/cache/puf_classified.rds"
year_col <- "puf_year"
pc  <- readRDS(puf_classified_path)
res <- analyze_midurethral_sling_patterns(
  pc, year_col = year_col,
  abog_npi_csv = "data/canonical_abog/canonical_abog_npi_LATEST.csv",
  urps_urology_npi_csv = "data/abu_urology/abu_urps_npi_LATEST.csv",
  exclude_years = tryCatch(config::get("exclude_years"), error = function(e) NULL),
  verbose = FALSE
)
pv <- res$provider_volume
dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)

# ── #5 Workforce dynamics ────────────────────────────────────────────────────
wf <- build_workforce_dynamics(pv, year_col)
readr::write_csv(wf$annual, "output/tables/table_11_workforce_dynamics.csv")
readr::write_csv(wf$entrants_by_specialty, "output/tables/table_11b_entrants_by_specialty.csv")
cat("=== #5 Annual workforce dynamics (newly observable; 2-year washout) ===\n")
print(as.data.frame(wf$annual |> mutate(pct_vol_entrant = round(pct_vol_entrant, 1))), row.names = FALSE)

# ── #6 Specialty-specific market-share trends ────────────────────────────────
sp_trend <- res$time_trends |>
  group_by(specialty_group) |>
  group_modify(~{
    m <- stats::lm(pct_slings_this_year ~ .x[[year_col]], .x); s <- summary(m)
    tibble::tibble(
      share_start = round(.x$pct_slings_this_year[which.min(.x[[year_col]])], 1),
      share_end   = round(.x$pct_slings_this_year[which.max(.x[[year_col]])], 1),
      slope_pp_yr = round(stats::coef(m)[2], 3),
      p_value     = signif(s$coefficients[2, 4], 3)
    )
  }) |> ungroup()
readr::write_csv(sp_trend, "output/tables/table_12_specialty_share_trends.csv")
cat("\n=== #6 Specialty-specific market-share trends ===\n")
print(as.data.frame(sp_trend), row.names = FALSE)

# ── #7 Geography (state level; no per-capita denominators) ───────────────────
spec <- pv |> distinct(Rndrng_NPI, specialty_group)
npi_state <- pc |>
  filter(HCPCS_Cd == "57288", puf_year != 2017) |>
  transmute(Rndrng_NPI = as.character(Rndrng_NPI), state = Rndrng_Prvdr_State_Abrvtn) |>
  count(Rndrng_NPI, state) |>
  group_by(Rndrng_NPI) |> slice_max(n, n = 1, with_ties = FALSE) |> ungroup() |>
  select(Rndrng_NPI, state)
geo <- spec |> left_join(npi_state, by = "Rndrng_NPI") |> filter(!is.na(state)) |>
  group_by(state) |>
  summarise(
    n_observable_surgeons = n(),
    n_urps                = sum(specialty_group == "URPS"),
    urps_share_pct        = round(100 * sum(specialty_group == "URPS") / n(), 1),
    has_observable_urps   = sum(specialty_group == "URPS") > 0,
    .groups = "drop"
  ) |> arrange(desc(n_observable_surgeons))
readr::write_csv(geo, "output/tables/table_13_geography_by_state.csv")
cat("\n=== #7 States with NO observable URPS surgeon (>=11 slings in any year) ===\n")
print(as.data.frame(geo |> filter(!has_observable_urps)), row.names = FALSE)
cat(sprintf("\n%d states/territories; %d total observable surgeons.\n",
            nrow(geo), sum(geo$n_observable_surgeons)))
