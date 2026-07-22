# =============================================================================
# recompute_gynecologic_share.R
#
# Recompute the annual market-share trend under the COMBINED-URPS taxonomy
# (config exclude_years applied; currently none). Because urology-pathway URPS surgeons are now inside URPS,
# "URPS + MIGS + General OB/GYN" is no longer purely OB/GYN-trained, so this
# script reports several complementary share definitions and regresses each on
# calendar year:
#
#   urps_combined   URPS share (both training pathways) — new headline group
#   gyn_trained     OB/GYN-residency-trained share = ABOG-URPS + MIGS +
#                   General OB/GYN — the SAME definition as the manuscript's
#                   original "combined gynecologic share" (directly comparable)
#   spec_gyn_grp    URPS + MIGS + General OB/GYN by specialty_group label —
#                   INFLATED, double-labels urology-pathway URPS as gynecologic;
#                   do NOT call this "gynecologic"
#   urology_nonurps non-URPS urology share (the declining complement)
#
# Gyn- vs uro-pathway URPS are told apart by subspecialty_abog: ABOG-matched
# (gyn pathway) is non-NA; ABU-only (urology pathway) is NA.
#
# Writes: output/tables/table_7_share_trends.csv
# Usage:  Rscript scripts/recompute_gynecologic_share.R [puf_classified.rds]
# =============================================================================

suppressWarnings(suppressMessages(library(dplyr)))
source("R/reporting_stats_helpers.R")
source("R/analyze_sling_patterns.R")

args <- commandArgs(trailingOnly = TRUE)
puf_classified_path <- if (length(args) >= 1) args[[1]] else
  "/Volumes/MufflySamsung 1/sling-volume-patterns/data/cache/puf_classified.rds"
year_col      <- "puf_year"
exclude_years <- tryCatch(config::get("exclude_years"), error = function(e) NULL)

stopifnot(file.exists(puf_classified_path))
res <- analyze_midurethral_sling_patterns(
  medicare_puf_data    = readRDS(puf_classified_path),
  year_col             = year_col,
  abog_npi_csv         = "data/canonical_abog/canonical_abog_npi_LATEST.csv",
  urps_urology_npi_csv = "data/abu_urology/abu_urps_npi_LATEST.csv",
  exclude_years        = exclude_years,
  verbose              = FALSE
)
pv <- res$provider_volume

yearly <- pv |>
  mutate(grp = case_when(
    specialty_group == "URPS" & !is.na(subspecialty_abog) ~ "urps_gyn",
    specialty_group == "URPS" &  is.na(subspecialty_abog) ~ "urps_uro",
    TRUE ~ specialty_group
  )) |>
  group_by(.data[[year_col]], grp) |>
  summarise(n = sum(annual_sling_count), .groups = "drop") |>
  group_by(.data[[year_col]]) |>
  mutate(tot = sum(n)) |>
  ungroup()

share <- yearly |>
  group_by(.data[[year_col]], tot) |>
  summarise(
    urps_combined   = 100 * sum(n[grp %in% c("urps_gyn", "urps_uro")]) / first(tot),
    gyn_trained     = 100 * sum(n[grp %in% c("urps_gyn", "MIGS", "General OB/GYN")]) / first(tot),
    spec_gyn_grp    = 100 * sum(n[grp %in% c("urps_gyn", "urps_uro", "MIGS", "General OB/GYN")]) / first(tot),
    urology_nonurps = 100 * sum(n[grp == "Urology"]) / first(tot),
    .groups = "drop"
  ) |>
  arrange(.data[[year_col]])

fit_share <- function(label, y) {
  yr <- share[[year_col]]
  m  <- stats::lm(y ~ yr); s <- summary(m)
  p  <- s$coefficients[2, 4]
  tibble::tibble(
    definition   = label,
    start_year   = yr[1], start_pct = round(y[1], 1),
    end_year     = yr[length(yr)], end_pct = round(y[length(y)], 1),
    slope_pp_yr  = round(coef(m)[2], 3),
    r_squared    = round(s$r.squared, 3),
    p_value      = p,
    p_formatted  = ifelse(p < 0.001, "<0.001", sprintf("%.3f", p))
  )
}

trends <- dplyr::bind_rows(
  fit_share("URPS (combined, both pathways)",                 share$urps_combined),
  fit_share("Gynecology-trained (ABOG-URPS + MIGS + Gen OB/GYN)", share$gyn_trained),
  fit_share("Specialty-group gyn (URPS + MIGS + Gen OB/GYN) [inflated]", share$spec_gyn_grp),
  fit_share("Urology (non-URPS)",                             share$urology_nonurps)
)

dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)
readr::write_csv(trends, "output/tables/table_7_share_trends.csv")

cat("=== Annual shares (%), all years ===\n")
print(as.data.frame(share |> rename(year = !!year_col) |>
  mutate(across(c(urps_combined, gyn_trained, spec_gyn_grp, urology_nonurps),
                ~round(.x, 1)))), row.names = FALSE)
cat("\n=== Share trends (OLS ~ year) → output/tables/table_7_share_trends.csv ===\n")
print(as.data.frame(trends |> select(-p_value)), row.names = FALSE)
