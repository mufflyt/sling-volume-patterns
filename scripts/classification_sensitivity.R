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

# ── Fourth scheme: true time-varying, cert-gated by ABOG sub1startdate ────────
# A physician counts as URPS/MIGS only from their subspecialty certification
# year onward; pre-certification years revert to their CMS-based group. This
# requires the CMS-only base classification (no ABOG/ABU split) as the fallback.
certyear_path <- tryCatch(config::get("abog_subspecialty_certyear_csv"),
                          error = function(e) NULL)
if (!is.null(certyear_path) && file.exists(certyear_path)) {
  base <- analyze_midurethral_sling_patterns(
    readRDS(puf_classified_path), year_col = year_col,
    abog_npi_csv = NULL, urps_urology_npi_csv = NULL,
    exclude_years = tryCatch(config::get("exclude_years"), error = function(e) NULL),
    verbose = FALSE
  )$provider_volume |>
    dplyr::mutate(specialty_group = ifelse(specialty_group == "OB/GYN",
                                           "General OB/GYN", specialty_group))
  cw  <- readr::read_csv(certyear_path, show_col_types = FALSE) |>
    dplyr::mutate(npi = as.character(npi))
  abu <- readr::read_csv("data/abu_urology/abu_urps_npi_LATEST.csv",
                         show_col_types = FALSE)$npi
  # ABOG URPS/MIGS gated by cert year; ABU urology-pathway URPS kept fixed
  # (no urology-FPMRS certification date is available).
  tv <- assign_time_varying_certgated(base, year_col, cw) |>
    dplyr::mutate(specialty_group = ifelse(
      Rndrng_NPI %in% abu & specialty_group != "MIGS", "URPS", specialty_group))
  s_tv <- summarise_scheme(tv, year_col, "Time-varying cert-gated (ABOG sub1startdate)")
  summaries <- c(summaries, list(s_tv))
} else {
  message("[classification] no cert-year crosswalk — skipping cert-gated scheme.")
}

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

cat("\nNote: the cert-gated scheme uses the ABOG sub1startdate (true FPMRS/MIG\n",
    "subspecialty certification date, 2013-2024) to switch physicians into URPS/\n",
    "MIGS only from their certification year; urology-pathway URPS remain fixed\n",
    "(no urology-FPMRS certification date is available).\n", sep = "")
