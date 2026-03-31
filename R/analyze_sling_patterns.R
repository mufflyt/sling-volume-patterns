# =============================================================================
# analyze_sling_patterns.R
#
# Who is performing midurethral sling procedures (CPT 57288) in Medicare?
# Specialty and volume pattern analysis from the CMS Physician and Other
# Practitioners Public Use File (Medicare PUF).
#
# Data source:
#   CMS Medicare Physician & Other Practitioners PUF
#   https://data.cms.gov/provider-summary-by-type-of-service/
#     medicare-physician-other-practitioners/
#     medicare-physician-other-practitioners-by-provider-and-service
#
# Authors: Tyler Muffly, MD
# =============================================================================


# =============================================================================
# HELPER FUNCTIONS (not exported)
# =============================================================================

#' @noRd
log_msg <- function(msg, verbose = TRUE) {
  if (isTRUE(verbose)) {
    message(glue::glue(
      "[{format(Sys.time(), '%Y-%m-%d %H:%M:%S')}] {msg}"
    ))
  }
  invisible(NULL)
}

#' @noRd
validate_sling_input <- function(medicare_puf_data, year_col = NULL) {
  assertthat::assert_that(
    is.data.frame(medicare_puf_data),
    msg = "medicare_puf_data must be a data frame or tibble."
  )
  required_columns <- c(
    "Rndrng_NPI",
    "Rndrng_Prvdr_Type",
    "HCPCS_Cd",
    "Tot_Srvcs"
  )
  missing_columns <- setdiff(required_columns, names(medicare_puf_data))
  assertthat::assert_that(
    length(missing_columns) == 0L,
    msg = glue::glue(
      "medicare_puf_data is missing required columns: ",
      "{paste(missing_columns, collapse = ', ')}"
    )
  )
  assertthat::assert_that(
    nrow(medicare_puf_data) > 0L,
    msg = "medicare_puf_data must contain at least one row."
  )
  assertthat::assert_that(
    is.character(medicare_puf_data$Rndrng_NPI) ||
      is.numeric(medicare_puf_data$Rndrng_NPI),
    msg = "Rndrng_NPI must be character or numeric."
  )
  assertthat::assert_that(
    is.character(medicare_puf_data$Rndrng_Prvdr_Type),
    msg = "Rndrng_Prvdr_Type must be a character column."
  )
  assertthat::assert_that(
    is.numeric(medicare_puf_data$Tot_Srvcs),
    msg = "Tot_Srvcs must be numeric."
  )
  if (!is.null(year_col)) {
    assertthat::assert_that(
      is.character(year_col) && length(year_col) == 1L,
      msg = "year_col must be a single character string."
    )
    assertthat::assert_that(
      year_col %in% names(medicare_puf_data),
      msg = glue::glue(
        "year_col '{year_col}' not found in medicare_puf_data. ",
        "Available columns: {paste(names(medicare_puf_data), collapse = ', ')}"
      )
    )
  }
  invisible(TRUE)
}

#' @noRd
classify_provider_specialty <- function(provider_type_vector) {
  assertthat::assert_that(
    is.character(provider_type_vector),
    msg = "provider_type_vector must be a character vector."
  )
  # Mutually exclusive hierarchy:
  #   1. FPMRS (urogynecology keywords win)
  #   2. OB/GYN (obstetrics / gynecology keywords)
  #   3. Urology
  #   4. Other (catch-all)
  dplyr::case_when(
    stringr::str_detect(
      provider_type_vector,
      stringr::regex(
        "urogynecol|female pelvic|pelvic medicine|pelvic floor",
        ignore_case = TRUE
      )
    ) ~ "FPMRS",
    stringr::str_detect(
      provider_type_vector,
      stringr::regex(
        "obstetrics|gynecolog|ob/gyn|ob-gyn",
        ignore_case = TRUE
      )
    ) ~ "OB/GYN",
    stringr::str_detect(
      provider_type_vector,
      stringr::regex("^urolog|\\burolog", ignore_case = TRUE)
    ) ~ "Urology",
    TRUE ~ "Other"
  )
}

#' @noRd
assign_volume_tier <- function(annual_count_vector, low_volume_threshold) {
  assertthat::assert_that(
    is.numeric(annual_count_vector),
    msg = "annual_count_vector must be numeric."
  )
  # NOTE: is.numeric() returns TRUE for integer vectors in R, so the
  # is.integer() branch below is not needed — kept as is.numeric() only.
  assertthat::assert_that(
    is.numeric(low_volume_threshold),
    msg = "low_volume_threshold must be numeric."
  )
  # Bug fix: floor() ensures the label boundary is always a whole number.
  # Without floor(), threshold=7 would produce "Medium (7–16.5/yr)", which
  # looks unprofessional in a published table and confuses readers.
  medium_upper <- floor(low_volume_threshold * 2.5 - 1)
  dplyr::case_when(
    annual_count_vector < low_volume_threshold ~
      glue::glue("Low (<{low_volume_threshold}/yr)"),
    annual_count_vector <= medium_upper ~
      glue::glue(
        "Medium ({low_volume_threshold}\u2013{medium_upper}/yr)"
      ),
    TRUE ~
      glue::glue("High (>{medium_upper}/yr)")
  )
}

# =============================================================================
# PATTERN 5: PARAMETERIZED THRESHOLD HELPERS
# (from cas-bioinf/covid19retrospective + oyaxbell/pasc_ensanut)
# Analogous to surv_data_at_day(patient_data, day) — generates analysis-ready
# datasets at different volume cutoffs without copy-pasting analysis blocks.
# =============================================================================

#' @noRd
#' @description
#' Apply multiple low-volume threshold definitions simultaneously to a vector
#' of annual procedure counts, returning one classification column per threshold.
#' Enables systematic multi-definition sensitivity analysis without repeating
#' the analysis block for each threshold.
#'
#' Pattern from oyaxbell/pasc_ensanut: PASC defined simultaneously under WHO
#' and score-based criteria; results compared across definitions.
classify_volume_multi <- function(
    annual_count_vector,
    thresholds = c(5L, 10L, 25L)
) {
  assertthat::assert_that(
    is.numeric(annual_count_vector),
    msg = "classify_volume_multi: annual_count_vector must be numeric."
  )
  assertthat::assert_that(
    is.numeric(thresholds) && length(thresholds) >= 1L,
    msg = "classify_volume_multi: thresholds must be a non-empty numeric vector."
  )
  assertthat::assert_that(
    all(thresholds > 0),
    msg = "classify_volume_multi: all threshold values must be positive."
  )

  # Build one logical column per threshold: TRUE = low-volume at that cutoff
  purrr::map(
    thresholds,
    function(t) annual_count_vector < t
  ) |>
    purrr::set_names(glue::glue("is_low_vol_lt{thresholds}")) |>
    tibble::as_tibble()
}

#' @noRd
#' @description
#' Prepare a classified PUF for analysis at a specified volume threshold,
#' optionally subsetting to a single year. Equivalent to the
#' surv_data_at_day(patient_data, day) pattern from covid19retrospective.
#' Avoids copy-pasting analysis setup for each sensitivity variant.
claims_at_volume_threshold <- function(
    classified_puf_data,
    low_threshold,
    year_col    = NULL,
    target_year = NULL,
    verbose     = TRUE
) {
  assertthat::assert_that(
    is.data.frame(classified_puf_data),
    msg = "claims_at_volume_threshold: classified_puf_data must be a data frame."
  )
  assertthat::assert_that(
    is.numeric(low_threshold) && length(low_threshold) == 1L && low_threshold > 0,
    msg = "claims_at_volume_threshold: low_threshold must be a single positive number."
  )

  n_in <- nrow(classified_puf_data)

  # Optionally subset to a single calendar year
  if (!is.null(year_col) && !is.null(target_year)) {
    assertthat::assert_that(
      year_col %in% names(classified_puf_data),
      msg = glue::glue(
        "claims_at_volume_threshold: year_col '{year_col}' not found."
      )
    )
    classified_puf_data <- dplyr::filter(
      classified_puf_data,
      .data[[year_col]] == target_year
    )
    assertthat::assert_that(
      nrow(classified_puf_data) > 0L,
      msg = glue::glue(
        "claims_at_volume_threshold: no rows remain after filtering to ",
        "{year_col} == {target_year}. Check target_year value."
      )
    )
  }

  if (isTRUE(verbose)) {
    year_note <- if (!is.null(target_year)) glue::glue(", year={target_year}") else ""
    message(glue::glue(
      "[{format(Sys.time(), '%Y-%m-%d %H:%M:%S')}] ",
      "claims_at_volume_threshold: threshold={low_threshold}{year_note}, ",
      "{format(nrow(classified_puf_data), big.mark=',')} rows ",
      "(from {format(n_in, big.mark=',')})"
    ))
  }

  # Bug fix B4: low_threshold was validated and logged but never applied or
  # attached to the returned data. Callers had no way to verify that the
  # threshold used here matches the one passed to analyze_midurethral_sling_
  # patterns() downstream, opening a silent mismatch bug. Attach as an
  # attribute so downstream code can assert consistency:
  #   stopifnot(attr(df, "intended_low_vol_threshold") == low_threshold)
  attr(classified_puf_data, "intended_low_vol_threshold") <- low_threshold
  classified_puf_data
}

#' @noRd
filter_to_sling_cpt <- function(medicare_puf_data, verbose = TRUE) {
  pre_filter_row_count <- nrow(medicare_puf_data)
  sling_rows <- dplyr::filter(medicare_puf_data, HCPCS_Cd == "57288")
  post_filter_row_count <- nrow(sling_rows)
  log_msg(
    glue::glue(
      "CPT 57288 filter: {pre_filter_row_count} rows in \u2192 ",
      "{post_filter_row_count} rows retained ",
      "({pre_filter_row_count - post_filter_row_count} non-sling rows dropped)"
    ),
    verbose = verbose
  )
  assertthat::assert_that(
    post_filter_row_count > 0L,
    msg = paste0(
      "No records with HCPCS_Cd == '57288' found. ",
      "Verify the input data contains midurethral sling claims."
    )
  )
  sling_rows
}

#' @noRd
aggregate_to_provider_level <- function(
    sling_data,
    year_col = NULL,
    verbose  = TRUE
) {
  grouping_columns <- c("Rndrng_NPI", "Rndrng_Prvdr_Type", "specialty_group")
  if (!is.null(year_col)) {
    grouping_columns <- c(grouping_columns, year_col)
  }
  provider_rows <- sling_data |>
    dplyr::group_by(dplyr::across(dplyr::all_of(grouping_columns))) |>
    dplyr::summarise(
      annual_sling_count = sum(Tot_Srvcs, na.rm = TRUE),
      .groups            = "drop"
    )

  # Bug fix: In real Medicare PUF data, the same NPI can appear with two
  # different Rndrng_Prvdr_Type strings (data quality issue). Grouping by
  # NPI + provider_type would silently produce two rows for that NPI,
  # breaking all downstream uniqueness invariants. Detect and fail loudly.
  uniqueness_check_columns <- if (!is.null(year_col)) {
    c("Rndrng_NPI", year_col)
  } else {
    "Rndrng_NPI"
  }
  npi_row_counts <- provider_rows |>
    dplyr::count(dplyr::across(dplyr::all_of(uniqueness_check_columns)))
  n_duplicate_npis <- sum(npi_row_counts$n > 1L, na.rm = TRUE)
  assertthat::assert_that(
    n_duplicate_npis == 0L,
    msg = glue::glue(
      "{n_duplicate_npis} NPI(s) appear with more than one ",
      "Rndrng_Prvdr_Type value in the sling claims. This violates the ",
      "one-row-per-NPI invariant. Inspect for conflicting provider type ",
      "strings for the same NPI and deduplicate before calling this function."
    )
  )

  log_msg(
    glue::glue(
      "Provider-level aggregation complete: ",
      "{nrow(provider_rows)} provider",
      "{if (!is.null(year_col)) '-year' else ''} rows ",
      "(uniqueness invariant verified)"
    ),
    verbose = verbose
  )
  provider_rows
}

#' @noRd
build_specialty_summary <- function(
    provider_volume_data,
    low_volume_threshold,
    verbose = TRUE
) {
  grand_total_slings <- sum(
    provider_volume_data$annual_sling_count, na.rm = TRUE
  )
  # Bug fix B2: Guard against silent division-by-zero. sum(..., na.rm=TRUE)
  # returns 0 when all values are NA, causing pct_of_all_slings = NaN/Inf.
  assertthat::assert_that(
    grand_total_slings > 0,
    msg = paste0(
      "build_specialty_summary: grand total slings is 0. ",
      "Check that Tot_Srvcs contains at least some non-NA positive values."
    )
  )
  specialty_level_summary <- provider_volume_data |>
    dplyr::group_by(specialty_group) |>
    dplyr::summarise(
      n_providers           = dplyr::n_distinct(Rndrng_NPI),
      total_slings          = sum(annual_sling_count, na.rm = TRUE),
      median_annual_volume  = stats::median(annual_sling_count, na.rm = TRUE),
      mean_annual_volume    = mean(annual_sling_count, na.rm = TRUE),
      # Bug fix: the previous code used sum(count < threshold) which, in
      # multi-year data, counts NPI-year rows — not unique providers.
      # An NPI low-volume in 2 of 3 years was counted twice.
      # Fix: count distinct NPIs where the condition holds at least once.
      n_low_volume_providers = dplyr::n_distinct(
        Rndrng_NPI[annual_sling_count < low_volume_threshold]
      ),
      pct_low_volume_providers = dplyr::n_distinct(
        Rndrng_NPI[annual_sling_count < low_volume_threshold]
      ) / dplyr::n_distinct(Rndrng_NPI) * 100,
      .groups = "drop"
    ) |>
    dplyr::mutate(
      pct_of_all_slings = total_slings / grand_total_slings * 100
    ) |>
    dplyr::arrange(dplyr::desc(total_slings))

  log_msg(
    glue::glue(
      "Specialty summary built: {nrow(specialty_level_summary)} groups | ",
      "grand total slings = {format(grand_total_slings, big.mark = ',')}"
    ),
    verbose = verbose
  )
  specialty_level_summary
}

#' @noRd
build_low_volume_burden <- function(
    provider_volume_data,
    low_volume_threshold,
    verbose = TRUE
) {
  # Bug fix B1: In multi-year mode, the previous code applied
  # `is_low_volume_provider = annual_sling_count < threshold` per NPI-year
  # row, then grouped by that flag. A provider low-volume in 2020 and
  # high-volume in 2021 appeared in BOTH the TRUE and FALSE strata, causing
  # n_providers to sum to more than the actual number of unique providers
  # and pct_of_all_slings to potentially exceed 100.
  #
  # Fix: collapse to one row per NPI using mean annual sling count, then
  # classify. Each NPI lands in exactly one stratum regardless of how many
  # years of data are present. For single-year data (no year_col), mean of
  # one value equals that value — behaviour is identical to before.
  npi_mean_volume <- provider_volume_data |>
    dplyr::group_by(Rndrng_NPI, specialty_group) |>
    dplyr::summarise(
      mean_annual_sling_count = mean(annual_sling_count, na.rm = TRUE),
      total_slings_all_years  = sum(annual_sling_count,  na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      is_low_volume_provider = mean_annual_sling_count < low_volume_threshold
    )

  # Bug fix B3: Guard against division-by-zero when all sling counts are NA.
  total_slings_all <- sum(npi_mean_volume$total_slings_all_years, na.rm = TRUE)
  assertthat::assert_that(
    total_slings_all > 0,
    msg = paste0(
      "build_low_volume_burden: total slings across all providers is 0. ",
      "Check that Tot_Srvcs contains at least some non-NA positive values."
    )
  )

  low_volume_burden_summary <- npi_mean_volume |>
    dplyr::group_by(specialty_group, is_low_volume_provider) |>
    dplyr::summarise(
      n_providers  = dplyr::n_distinct(Rndrng_NPI),
      total_slings = sum(total_slings_all_years, na.rm = TRUE),
      .groups      = "drop"
    ) |>
    dplyr::mutate(
      pct_of_all_slings = total_slings / total_slings_all * 100
    )

  log_msg(
    glue::glue(
      "Low-volume burden table built ",
      "(threshold = {low_volume_threshold}/yr, classification by mean ",
      "annual volume per NPI): {nrow(low_volume_burden_summary)} rows"
    ),
    verbose = verbose
  )
  low_volume_burden_summary
}

#' @noRd
build_time_trends <- function(
    provider_volume_data,
    year_col,
    verbose = TRUE
) {
  annual_specialty_trends <- provider_volume_data |>
    dplyr::group_by(
      dplyr::across(dplyr::all_of(c(year_col, "specialty_group")))
    ) |>
    dplyr::summarise(
      total_slings          = sum(annual_sling_count, na.rm = TRUE),
      n_providers           = dplyr::n_distinct(Rndrng_NPI),
      median_annual_volume  = stats::median(annual_sling_count, na.rm = TRUE),
      .groups               = "drop"
    ) |>
    # Bug fix: pct_slings_this_year was missing. Absolute counts alone are
    # insufficient for Figure 1 — reviewers will ask about market share
    # trends, not just volume. Compute share within each year grouping.
    dplyr::group_by(dplyr::across(dplyr::all_of(year_col))) |>
    dplyr::mutate(
      pct_slings_this_year = total_slings / sum(total_slings, na.rm = TRUE) * 100
    ) |>
    dplyr::ungroup() |>
    dplyr::arrange(
      dplyr::across(dplyr::all_of(c(year_col, "specialty_group")))
    )
  log_msg(
    glue::glue(
      "Time trends computed: {nrow(annual_specialty_trends)} specialty-year rows | ",
      "years: {paste(sort(unique(provider_volume_data[[year_col]])), collapse = ', ')}"
    ),
    verbose = verbose
  )
  annual_specialty_trends
}


# =============================================================================
# MAIN EXPORTED FUNCTION
# =============================================================================

#' Analyze Midurethral Sling Procedure Patterns in Medicare Data
#'
#' @description
#' Classifies every provider billing CPT 57288 (midurethral sling) in the
#' CMS Medicare Physician and Other Practitioners Public Use File into one
#' of four mutually exclusive specialty groups — FPMRS (urogynecology),
#' OB/GYN, Urology, or Other — using a deterministic hierarchical taxonomy
#' applied to the \code{Rndrng_Prvdr_Type} column supplied directly by CMS.
#' The function then summarises annual procedure volume, the low-volume
#' surgeon burden within each specialty, and (optionally) annual time trends.
#'
#' @details
#' ## Specialty Classification Hierarchy
#' Classification is mutually exclusive and applied in priority order.
#' The first matching rule wins:
#' \enumerate{
#'   \item \strong{FPMRS} — \code{Rndrng_Prvdr_Type} matches
#'     (case-insensitive): \emph{urogynecol}, \emph{female pelvic},
#'     \emph{pelvic medicine}, or \emph{pelvic floor}
#'   \item \strong{OB/GYN} — matches: \emph{obstetrics},
#'     \emph{gynecolog}, \emph{ob/gyn}, or \emph{ob-gyn}
#'   \item \strong{Urology} — matches: \emph{urolog}
#'     (anchored at word boundary to exclude unrelated specialties)
#'   \item \strong{Other} — all remaining provider types
#' }
#' To use an alternative taxonomy (e.g., collapsed Gynecologic vs Urology),
#' pre-recode the \code{specialty_group} column in the classified data and
#' call the internal aggregation helpers directly — see the pipeline script
#' \code{03_run_primary_analysis_sens.R} for a worked example.
#'
#' ## Low-Volume Surgeon Definition
#' A provider is classified as "low-volume" when their mean annual sling
#' count across all study years is strictly below \code{low_volume_threshold}
#' (default 10). In multi-year mode the mean is used (not any single year),
#' so a provider who temporarily dips below the threshold in one year is not
#' penalised. This approach matches the per-provider mean used in surgical
#' quality and credentialing literature.
#'
#' ## NPI Uniqueness Invariant
#' Each NPI must appear with only one \code{Rndrng_Prvdr_Type} string in
#' the input. If the same NPI has two different provider-type strings (a
#' known CMS data-quality issue), the function stops with an informative
#' error rather than silently double-counting that provider. Deduplicate
#' or resolve conflicting provider-type strings before calling this function.
#'
#' ## CMS Suppression Policy
#' CMS suppresses service counts of 1–10 in the PUF. In some releases the
#' suppressed value appears as an asterisk (converted to \code{NA} by
#' \code{readr::col_double()}); in others it appears as a small integer.
#' Both cases are handled upstream in \code{01_build_puf_cache.R} by
#' flagging rows with \code{is_cms_suppressed}. Suppressed rows are NOT
#' excluded from this function; their NPI and specialty remain valid even
#' if the exact count is unknown. Downstream volume statistics treat
#' \code{NA} service counts as 0 via \code{na.rm = TRUE} in all
#' \code{sum()} calls.
#'
#' ## Data Source
#' CMS Medicare Physician & Other Practitioners Public Use File:
#' \url{https://data.cms.gov/provider-summary-by-type-of-service/medicare-physician-other-practitioners/medicare-physician-other-practitioners-by-provider-and-service}
#'
#' Required columns: \code{Rndrng_NPI}, \code{Rndrng_Prvdr_Type},
#' \code{HCPCS_Cd}, \code{Tot_Srvcs}. The input may contain any HCPCS
#' codes; non-57288 rows are silently discarded in Step 1.
#'
#' @param medicare_puf_data A data frame or tibble containing Medicare
#'   Physician & Other Practitioners PUF records (one row per
#'   NPI\eqn{\times}HCPCS combination per year). Required columns:
#'   \code{Rndrng_NPI} (character or numeric NPI),
#'   \code{Rndrng_Prvdr_Type} (character; CMS-reported specialty string),
#'   \code{HCPCS_Cd} (character; procedure code), and
#'   \code{Tot_Srvcs} (numeric; Medicare-allowed service count).
#'   Additional columns are ignored.
#' @param year_col Character string or \code{NULL}. Name of the column
#'   in \code{medicare_puf_data} that encodes the calendar year (e.g.,
#'   \code{"puf_year"} or \code{"claim_year"}). When non-\code{NULL},
#'   provider-level volume is aggregated per NPI per year and a
#'   \code{time_trends} tibble is returned. Pass \code{NULL} (the default)
#'   for a cross-sectional analysis of a single year.
#' @param low_volume_threshold A single positive number. Annual sling count
#'   strictly below this value defines a "low-volume" provider. Default
#'   \code{10L}. Common sensitivity alternatives: \code{5L} (strict),
#'   \code{25L} (lenient). Must match the value passed to
#'   \code{\link{generate_sling_abstract}()} so the published abstract
#'   text agrees with the analysis numbers.
#' @param verbose Logical scalar. When \code{TRUE} (the default),
#'   timestamped progress messages are written to the console at each of
#'   the six internal pipeline steps (filter → classify → aggregate →
#'   specialty summary → low-volume burden → time trends). Set to
#'   \code{FALSE} for silent batch operation (e.g., inside
#'   \code{04_run_sensitivity_analyses.R}).
#'
#' @return A named list with four elements:
#' \describe{
#'   \item{\code{provider_volume}}{Tibble. One row per provider-year
#'     (or per provider when \code{year_col = NULL}). Columns:
#'     \code{Rndrng_NPI} (chr), \code{Rndrng_Prvdr_Type} (chr),
#'     \code{specialty_group} (chr; one of FPMRS / OB/GYN / Urology /
#'     Other), \code{annual_sling_count} (int; sum of \code{Tot_Srvcs}),
#'     \code{volume_tier} (chr; Low / Medium / High relative to
#'     \code{low_volume_threshold}). If \code{year_col} was supplied,
#'     the year column is also present.}
#'   \item{\code{specialty_summary}}{Tibble. One row per specialty group
#'     (at most 4 rows). Columns: \code{specialty_group},
#'     \code{n_providers} (count of distinct NPIs), \code{total_slings}
#'     (sum across all years), \code{median_annual_volume},
#'     \code{mean_annual_volume}, \code{n_low_volume_providers}
#'     (distinct NPIs whose mean annual count < threshold),
#'     \code{pct_low_volume_providers} (\%), \code{pct_of_all_slings}
#'     (\%). Sorted descending by \code{total_slings}.}
#'   \item{\code{low_volume_burden}}{Tibble. One row per specialty ×
#'     low-volume-stratum combination (at most 8 rows). Columns:
#'     \code{specialty_group}, \code{is_low_volume_provider} (logical;
#'     based on mean annual volume), \code{n_providers},
#'     \code{total_slings}, \code{pct_of_all_slings}.}
#'   \item{\code{time_trends}}{\code{NULL} when \code{year_col = NULL}.
#'     Otherwise a tibble with one row per specialty-year. Columns:
#'     the year column (named as supplied in \code{year_col}),
#'     \code{specialty_group}, \code{total_slings}, \code{n_providers},
#'     \code{median_annual_volume}, \code{pct_slings_this_year}
#'     (each specialty's share of all slings billed that calendar year;
#'     sums to 100 within each year). Sorted by year then specialty.}
#' }
#'
#' @note
#' The \code{low_volume_threshold} value must be identical in this function
#' and in \code{\link{generate_sling_abstract}()} so that the abstract's
#' prose ("fewer than X procedures per year") agrees with the computed
#' statistics. The \code{config.yml} entry
#' \code{low_volume_threshold_primary} is the single source of truth for
#' this value across the pipeline.
#'
#' @seealso
#' \code{\link{generate_sling_abstract}()} for converting the output of
#' this function into a publication-ready abstract with p-values.
#'
#' CMS PUF documentation:
#' \url{https://data.cms.gov/provider-summary-by-type-of-service/medicare-physician-other-practitioners/medicare-physician-other-practitioners-by-provider-and-service}
#'
#' @author Tyler Muffly, MD
#'
#' @references
#' Centers for Medicare & Medicaid Services. Medicare Physician & Other
#' Practitioners Public Use File, calendar years 2017–2023.
#' \url{https://data.cms.gov}
#'
#' Birkmeyer JD, Stukel TA, Siewers AE, et al. Surgeon volume and operative
#' mortality in the United States. \emph{N Engl J Med}. 2003;349(22):2117–27.
#' \doi{10.1056/NEJMsa035205}
#'
#' @family sling pipeline
#'
#' @examples
#' # ----------------------------------------------------------------
#' # Example 1 — Cross-sectional analysis (single year, no year_col)
#' # Uses default low_volume_threshold = 10, verbose = FALSE
#' # ----------------------------------------------------------------
#' \donttest{
#' synthetic_puf_single_year <- tibble::tibble(
#'   Rndrng_NPI        = as.character(c(
#'     1001, 1002, 1003,       # FPMRS — high-volume
#'     1004, 1005, 1006, 1007, # OB/GYN — all low-volume
#'     1008, 1009, 1010,       # Urology — mixed volume
#'     1011, 1012,             # Other — low-volume
#'     1013                    # Non-57288 (dropped internally)
#'   )),
#'   Rndrng_Prvdr_Type = c(
#'     rep("Urogynecology",            3),
#'     rep("Obstetrics & Gynecology",  4),
#'     rep("Urology",                  3),
#'     rep("Internal Medicine",        2),
#'     "Family Medicine"
#'   ),
#'   HCPCS_Cd  = c(rep("57288", 12), "99213"),
#'   Tot_Srvcs = c(
#'     45L, 38L, 52L,        # FPMRS: all >= 10 (high-volume)
#'     4L,  6L,  3L, 9L,    # OB/GYN: all < 10 (low-volume)
#'     14L, 8L, 20L,         # Urology: 1 low, 2 high
#'     3L,  7L,              # Other: both low-volume
#'     200L                  # non-sling — silently dropped
#'   )
#' )
#'
#' results_single <- analyze_midurethral_sling_patterns(
#'   medicare_puf_data    = synthetic_puf_single_year,
#'   year_col             = NULL,
#'   low_volume_threshold = 10L,
#'   verbose              = FALSE
#' )
#' # Specialty-level summary (corresponds to Table 1 in the manuscript)
#' print(results_single$specialty_summary)
#' #> # A tibble: 4 x 8
#' #>   specialty_group n_providers total_slings median_annual_volume ...
#' #>   <chr>                 <int>        <int>                <dbl>
#' #> 1 FPMRS                     3          135                   45
#' #> 2 Urology                   3           42                   14
#' #> 3 OB/GYN                    4           22                    5
#' #> 4 Other                     2           10                    5
#'
#' # All 4 OB/GYN providers are low-volume; 0 FPMRS providers are low-volume
#' print(results_single$specialty_summary[,
#'   c("specialty_group", "pct_low_volume_providers")
#' ])
#'
#' # time_trends is NULL for a cross-sectional analysis
#' stopifnot(is.null(results_single$time_trends))
#' }
#'
#' # ----------------------------------------------------------------
#' # Example 2 — Multi-year trend analysis with year_col
#' # Shows rising FPMRS market share 2020 -> 2022
#' # ----------------------------------------------------------------
#' \donttest{
#' synthetic_puf_multiyear <- tibble::tibble(
#'   Rndrng_NPI        = rep(as.character(1001:1012), times = 3),
#'   Rndrng_Prvdr_Type = rep(c(
#'     rep("Urogynecology",                       3),
#'     rep("Obstetrics & Gynecology",             4),
#'     rep("Urology",                             3),
#'     rep("Physical Medicine & Rehabilitation",  2)
#'   ), times = 3),
#'   HCPCS_Cd  = "57288",
#'   Tot_Srvcs = c(
#'     42L, 35L, 50L, 5L, 4L, 8L, 3L, 11L, 7L, 19L, 2L, 6L,  # 2020
#'     48L, 40L, 55L, 6L, 5L, 9L, 4L, 13L, 9L, 21L, 3L, 7L,  # 2021
#'     55L, 45L, 60L, 7L, 6L, 8L, 3L, 14L, 10L, 24L, 4L, 8L  # 2022
#'   ),
#'   year = rep(2020L:2022L, each = 12L)
#' )
#'
#' results_trend <- analyze_midurethral_sling_patterns(
#'   medicare_puf_data    = synthetic_puf_multiyear,
#'   year_col             = "year",
#'   low_volume_threshold = 10L,
#'   verbose              = FALSE
#' )
#' # Annual market-share trends by specialty (Figure 1 in the manuscript)
#' print(results_trend$time_trends)
#'
#' # Low-volume burden: which specialty bears the most low-volume surgeons?
#' print(results_trend$low_volume_burden)
#' }
#'
#' # ----------------------------------------------------------------
#' # Example 3 — Sensitivity analysis: strict threshold (5/yr)
#' # Demonstrates how pct_low_volume_providers shifts with threshold
#' # ----------------------------------------------------------------
#' \donttest{
#' results_strict <- analyze_midurethral_sling_patterns(
#'   medicare_puf_data    = synthetic_puf_multiyear,
#'   year_col             = "year",
#'   low_volume_threshold = 5L,
#'   verbose              = FALSE
#' )
#' # Compare low-volume burden at threshold 5 vs 10
#' print(results_strict$specialty_summary[,
#'   c("specialty_group", "n_providers",
#'     "pct_low_volume_providers", "pct_of_all_slings")
#' ])
#' # Fewer providers qualify as low-volume at the stricter 5/yr cutoff
#' print(results_strict$low_volume_burden)
#' }
#'
#' @importFrom dplyr filter mutate group_by summarise arrange desc
#'   across all_of n_distinct case_when ungroup count distinct pull
#'   bind_rows left_join if_else
#' @importFrom rlang sym
#' @importFrom stringr str_detect regex
#' @importFrom glue glue
#' @importFrom assertthat assert_that
#' @importFrom tibble tibble as_tibble
#' @importFrom stats median
#' @importFrom purrr walk map set_names
#'
#' @export
analyze_midurethral_sling_patterns <- function(
    medicare_puf_data,
    year_col             = NULL,
    low_volume_threshold = 10L,
    verbose              = TRUE
) {
  # ── 0. Input validation ────────────────────────────────────────────────────
  # Bug fix: verbose must be validated FIRST because log_msg() depends on it.
  # Previously the is.logical(verbose) check appeared after two log_msg()
  # calls and after validate_sling_input() — passing verbose = "yes" would
  # silently not log, then fail only when the explicit assertion was reached.
  assertthat::assert_that(
    is.logical(verbose) && length(verbose) == 1L,
    msg = "verbose must be a single TRUE or FALSE value."
  )

  log_msg(
    "══ analyze_midurethral_sling_patterns: START ══",
    verbose
  )
  log_msg(
    glue::glue(
      "Inputs — ",
      "nrow(medicare_puf_data): {nrow(medicare_puf_data)}, ",
      "ncol: {ncol(medicare_puf_data)}, ",
      "year_col: {if (is.null(year_col)) 'NULL' else year_col}, ",
      "low_volume_threshold: {low_volume_threshold}, ",
      "verbose: {verbose}"
    ),
    verbose
  )

  validate_sling_input(medicare_puf_data, year_col = year_col)

  assertthat::assert_that(
    is.numeric(low_volume_threshold) &&
      length(low_volume_threshold) == 1L,
    msg = "low_volume_threshold must be a single numeric or integer value."
  )
  assertthat::assert_that(
    low_volume_threshold > 0,
    msg = "low_volume_threshold must be a positive number."
  )

  # ── 1. Filter to CPT 57288 ─────────────────────────────────────────────────
  log_msg("Step 1 ▸ Filtering to CPT 57288 (midurethral sling).", verbose)
  sling_claims <- filter_to_sling_cpt(medicare_puf_data, verbose = verbose)

  # ── 2. Classify specialty ──────────────────────────────────────────────────
  log_msg("Step 2 ▸ Classifying providers into specialty groups.", verbose)
  sling_claims <- dplyr::mutate(
    sling_claims,
    specialty_group = classify_provider_specialty(Rndrng_Prvdr_Type)
  )

  specialty_record_counts <- dplyr::count(sling_claims, specialty_group)
  purrr::walk(
    seq_len(nrow(specialty_record_counts)),
    function(row_idx) {
      log_msg(
        glue::glue(
          "  {specialty_record_counts$specialty_group[row_idx]}: ",
          "{format(specialty_record_counts$n[row_idx], big.mark = ',')} records"
        ),
        verbose
      )
    }
  )

  # Bug fix: na.rm = TRUE required because NA == "Other" is NA, not FALSE.
  # sum() without na.rm propagates NA silently.
  n_unclassified <- sum(sling_claims$specialty_group == "Other", na.rm = TRUE)
  if (n_unclassified > 0) {
    other_types <- sling_claims |>
      dplyr::filter(specialty_group == "Other") |>
      dplyr::distinct(Rndrng_Prvdr_Type) |>
      dplyr::pull(Rndrng_Prvdr_Type)
    log_msg(
      glue::glue(
        "  Note: {n_unclassified} 'Other' records from provider types: ",
        "{paste(other_types, collapse = '; ')}"
      ),
      verbose
    )
  }

  # ── 3. Provider-level volume aggregation ───────────────────────────────────
  log_msg(
    "Step 3 ▸ Aggregating to provider-level annual sling counts.",
    verbose
  )
  provider_volume <- aggregate_to_provider_level(
    sling_claims,
    year_col = year_col,
    verbose  = verbose
  ) |>
    dplyr::mutate(
      volume_tier = assign_volume_tier(
        annual_sling_count,
        low_volume_threshold
      )
    )

  log_msg(
    glue::glue(
      "  Volume tiers assigned with threshold = {low_volume_threshold}/yr"
    ),
    verbose
  )

  # ── 4. Specialty summary table ─────────────────────────────────────────────
  log_msg(
    "Step 4 ▸ Building specialty-level summary (Table 1).",
    verbose
  )
  specialty_summary <- build_specialty_summary(
    provider_volume,
    low_volume_threshold = low_volume_threshold,
    verbose              = verbose
  )

  # ── 5. Low-volume burden table ─────────────────────────────────────────────
  log_msg(
    glue::glue(
      "Step 5 ▸ Building low-volume burden table ",
      "(threshold = {low_volume_threshold}/yr)."
    ),
    verbose
  )
  low_volume_burden <- build_low_volume_burden(
    provider_volume,
    low_volume_threshold = low_volume_threshold,
    verbose              = verbose
  )

  # ── 6. Time trends (optional) ──────────────────────────────────────────────
  time_trends <- NULL
  if (!is.null(year_col)) {
    log_msg(
      glue::glue(
        "Step 6 ▸ Computing annual time trends by specialty (year_col = ",
        "'{year_col}')."
      ),
      verbose
    )
    time_trends <- build_time_trends(
      provider_volume,
      year_col = year_col,
      verbose  = verbose
    )
  } else {
    log_msg(
      "Step 6 ▸ Skipped (year_col = NULL; time trends not requested).",
      verbose
    )
  }

  # ── 7. Assemble and log output ─────────────────────────────────────────────
  analysis_output <- list(
    provider_volume   = provider_volume,
    specialty_summary = specialty_summary,
    low_volume_burden = low_volume_burden,
    time_trends       = time_trends
  )

  log_msg("── Output summary ──────────────────────────────────", verbose)
  log_msg(
    glue::glue(
      "  provider_volume:   {nrow(analysis_output$provider_volume)} rows x ",
      "{ncol(analysis_output$provider_volume)} cols"
    ),
    verbose
  )
  log_msg(
    glue::glue(
      "  specialty_summary: {nrow(analysis_output$specialty_summary)} rows x ",
      "{ncol(analysis_output$specialty_summary)} cols"
    ),
    verbose
  )
  log_msg(
    glue::glue(
      "  low_volume_burden: {nrow(analysis_output$low_volume_burden)} rows x ",
      "{ncol(analysis_output$low_volume_burden)} cols"
    ),
    verbose
  )
  log_msg(
    glue::glue(
      "  time_trends:       ",
      "{if (is.null(time_trends)) 'NULL' else ",
      "paste0(nrow(time_trends), ' rows x ', ncol(time_trends), ' cols')}"
    ),
    verbose
  )
  log_msg(
    "══ analyze_midurethral_sling_patterns: COMPLETE ══",
    verbose
  )

  analysis_output
}
