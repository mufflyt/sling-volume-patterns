# =============================================================================
# build_ffs_denominator.R
#
# Load the female Original Medicare (fee-for-service) enrollment denominator and
# convert annual CPT 57288 service counts into rates per 100,000 female Part B
# FFS beneficiaries. This addresses reviewer point #2: raw fee-for-service
# counts lack an enrollment denominator, so a falling count can reflect the
# shrinking FFS population (migration to Medicare Advantage) rather than falling
# utilization.
#
# Source: CMS Program Statistics - Original Medicare Enrollment, table
# MDCR ENROLL AB 11 ("Part A and/or Part B Enrollees by Demographic
# Characteristics"), Sex -> Female row. See data/denominator/README.md.
#
# Authors: Tyler Muffly, MD
# =============================================================================

#' Classification options, read once from config (single source of truth).
#'
#' Every analysis path (pipeline step 03, compute_manuscript_values(), and the
#' supplementary-table scripts) calls this, so main and supplementary outputs
#' cannot drift apart. Falls back to the documented defaults if config is absent.
#' @return list(other_handling, split_urps_pathway)
classification_opts <- function() {
  oh <- tryCatch(config::get("other_handling"), error = function(e) NULL)
  su <- tryCatch(config::get("split_urps_pathway"), error = function(e) NULL)
  list(
    other_handling     = if (is.null(oh)) "separate" else as.character(oh),
    split_urps_pathway = if (is.null(su)) TRUE else isTRUE(su)
  )
}

#' Read the female FFS enrollment denominator.
#'
#' @param path CSV with columns year, female_ffs_partB (and the two other
#'   coverage variants). Defaults to config `ffs_denominator_csv`.
#' @param coverage Which coverage column to use as the denominator. Default
#'   "female_ffs_partB" (enrolled in Part B, the coverage a CPT 57288 claim
#'   requires); confirmed in data/denominator/README.md.
#' @return tibble(year, denominator) or NULL if the file is unavailable.
read_ffs_denominator <- function(path = NULL,
                                 coverage = "female_ffs_partB") {
  if (is.null(path)) {
    path <- tryCatch(config::get("ffs_denominator_csv"),
                     error = function(e) "data/denominator/female_ffs_denominator.csv")
  }
  if (is.null(path) || !file.exists(path)) return(NULL)
  d <- suppressWarnings(readr::read_csv(path, show_col_types = FALSE))
  if (!all(c("year", coverage) %in% names(d))) return(NULL)
  tibble::tibble(year = as.integer(d$year),
                 denominator = as.numeric(d[[coverage]]))
}

#' Attach a rate per 100,000 female Part B FFS beneficiaries to an annual table.
#'
#' @param annual data.frame with a year column and a `services` column (annual
#'   CPT 57288 service count).
#' @param year_col name of the year column in `annual`.
#' @param services_col name of the annual service-count column.
#' @param denom output of read_ffs_denominator(); if NULL the rate columns are
#'   returned as NA so downstream code degrades gracefully.
#' @return `annual` with added columns `denominator` and `rate_per_100k`.
attach_ffs_rate <- function(annual, year_col = "year",
                            services_col = "services", denom = NULL) {
  if (is.null(denom)) denom <- read_ffs_denominator()
  annual$year_int <- as.integer(annual[[year_col]])
  if (is.null(denom)) {
    annual$denominator   <- NA_real_
    annual$rate_per_100k <- NA_real_
    annual$year_int <- NULL
    return(annual)
  }
  m <- match(annual$year_int, denom$year)
  annual$denominator   <- denom$denominator[m]
  annual$rate_per_100k <- annual[[services_col]] / annual$denominator * 1e5
  annual$year_int <- NULL
  annual
}
