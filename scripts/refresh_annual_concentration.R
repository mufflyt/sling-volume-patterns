# =============================================================================
# refresh_annual_concentration.R
#
# Ad-hoc refresh: regenerate the annual-concentration tables/figures and the
# combined-URPS specialty summary WITHOUT re-reading the 30 GB raw PUF.
#
# Reads the frozen puf_classified.rds (filtered CPT 57288 rows, already merged
# across years) and re-runs the analysis with the ABOG (OB/GYN) crosswalk and
# the ABU (urology-pathway) URPS roster, then writes:
#   output/tables/table_5_annual_concentration.csv
#   output/tables/table_6_concentration_trends.csv
#   output/figures/figure_4_concentration_trends.png
#   output/figures/figure_5_supply_trends.png
#
# Usage:
#   Rscript scripts/refresh_annual_concentration.R \
#     "/Volumes/MufflySamsung 1/sling-volume-patterns/data/cache/puf_classified.rds"
# =============================================================================

suppressWarnings(suppressMessages({
  library(dplyr); library(ggplot2)
}))
source("R/reporting_stats_helpers.R")
source("R/analyze_sling_patterns.R")
source("R/annual_concentration_outputs.R")

args <- commandArgs(trailingOnly = TRUE)
puf_classified_path <- if (length(args) >= 1) args[[1]] else
  "/Volumes/MufflySamsung 1/sling-volume-patterns/data/cache/puf_classified.rds"
year_col   <- "puf_year"
year_breaks <- 2013:2023

stopifnot(file.exists(puf_classified_path))
pc <- readRDS(puf_classified_path)

res <- analyze_midurethral_sling_patterns(
  medicare_puf_data    = pc,
  year_col             = year_col,
  abog_npi_csv         = "data/canonical_abog/canonical_abog_npi_LATEST.csv",
  urps_urology_npi_csv = "data/abu_urology/abu_urps_npi_LATEST.csv",
  verbose              = FALSE
)

annual      <- res$annual_concentration
regressions <- build_concentration_trend_regressions(annual, year_col = year_col)

dir.create("output/tables",  recursive = TRUE, showWarnings = FALSE)
dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)

readr::write_csv(
  build_annual_concentration_table(annual, year_col = year_col),
  "output/tables/table_5_annual_concentration.csv"
)
readr::write_csv(
  build_trend_regression_table(regressions),
  "output/tables/table_6_concentration_trends.csv"
)

ggsave("output/figures/figure_4_concentration_trends.png",
       make_concentration_trend_figure(annual, year_col, year_breaks),
       width = 9, height = 7, dpi = 300, bg = "white")
ggsave("output/figures/figure_5_supply_trends.png",
       make_supply_trend_figure(annual, year_col, year_breaks),
       width = 9, height = 5, dpi = 300, bg = "white")

cat("Wrote Tables 5-6 and Figures 4-5.\n\n")

# ── Numbers for the expanded Results section ─────────────────────────────────
cat("=== Specialty summary (combined URPS) ===\n")
print(as.data.frame(res$specialty_summary |>
  transmute(specialty_group, n_providers, total_slings,
            pct = round(pct_of_all_slings, 1),
            median = median_annual_volume)), row.names = FALSE)

cat("\n=== Pooled multi-year Gini / top-20% (concentration_metrics) ===\n")
print(as.data.frame(res$concentration_metrics |>
  transmute(specialty_group, n_providers,
            gini = round(gini_coefficient, 3),
            top20 = round(pct_by_top_20, 1))), row.names = FALSE)

cat("\n=== Annual pooled 'All' concentration trend ===\n")
print(as.data.frame(annual |> filter(specialty_group == "All") |>
  transmute(puf_year, n_surgeons, n_procedures,
            gini = round(gini_coefficient, 3), hhi = round(hhi, 1),
            top20 = round(pct_by_top_20, 1),
            bottom50 = round(pct_by_bottom_50, 1))), row.names = FALSE)

cat("\n=== Key trend regressions (slope/yr, p) ===\n")
key <- regressions |>
  filter(measure %in% c("gini_coefficient", "hhi", "pct_by_top_20",
                        "n_procedures", "n_surgeons", "median_volume")) |>
  transmute(specialty_group, measure,
            start = round(start_value, 3), end = round(end_value, 3),
            slope = round(slope_per_year, 3), r2 = round(r_squared, 3), p = p_formatted)
print(as.data.frame(key), row.names = FALSE)
