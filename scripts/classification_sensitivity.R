# =============================================================================
# classification_sensitivity.R
#
# Specialty-classification sensitivity analysis (manuscript point #4): compares
# time-varying vs modal vs ever-URPS/MIGS assignment, since the primary
# conclusion concerns changes in specialty market share. Writes:
#   output/tables/table_10_classification_sensitivity.csv   (distribution)
#   output/tables/table_10b_classification_trends.csv        (share trends)
#
# Usage: Rscript scripts/classification_sensitivity.R [puf_classified.rds]
# =============================================================================

suppressWarnings(suppressMessages(library(dplyr)))
source("R/reporting_stats_helpers.R")
source("R/analyze_sling_patterns.R")
source("R/classification_schemes.R")

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

schemes <- c(time_varying = "Time-varying (per physician-year)",
             modal        = "Modal (single most-frequent specialty)",
             ever_urps_migs = "Ever URPS/MIGS")

summaries <- lapply(names(schemes), function(s) {
  summarise_scheme(assign_specialty_scheme(pv, s), year_col, schemes[[s]])
})

dist  <- dplyr::bind_rows(lapply(summaries, `[[`, "distribution"))
trend <- dplyr::bind_rows(lapply(summaries, `[[`, "trends"))

dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)
readr::write_csv(dist,  "output/tables/table_10_classification_sensitivity.csv")
readr::write_csv(trend, "output/tables/table_10b_classification_trends.csv")

fmt_p <- function(p) ifelse(p < 0.001, "<0.001", sprintf("%.3f", p))

cat("=== Specialty distribution by classification scheme (2017 excluded) ===\n")
print(as.data.frame(dist |>
  mutate(pct_of_all = round(pct_of_all, 1)) |>
  arrange(scheme, desc(procedures))), row.names = FALSE)

cat("\n=== Market-share TRENDS by scheme (pp/year) ===\n")
print(as.data.frame(trend |>
  transmute(scheme,
            `URPS slope` = urps_slope_pp_yr, `URPS p` = fmt_p(urps_p),
            `Gyn slope`  = gyn_slope_pp_yr,  `Gyn p`  = fmt_p(gyn_p))),
  row.names = FALSE)

cat("\nNote: ABOG supplies no certification date, so ABOG URPS/MIGS membership is\n",
    "fixed across years in every scheme; only CMS provider type varies annually.\n", sep = "")
