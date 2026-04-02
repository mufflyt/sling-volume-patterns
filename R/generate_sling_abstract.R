# =============================================================================
# generate_sling_abstract.R
#
# Programmatically fills and renders the structured abstract for:
#   "Specialty and Volume Patterns Among Physicians Performing Midurethral
#    Sling Procedures in Medicare Beneficiaries"
#
# Takes the list returned by analyze_midurethral_sling_patterns() and the
# raw provider_volume tibble, computes all statistics and p-values needed,
# then renders a complete abstract with every number, IQR, p-value, and
# adaptive phrase drawn directly from the data.
#
# CMS Medicare PUF provider types: OB/GYN, Urology, Other.
# There is no FPMRS category in the PUF. The focal comparison is
# OB/GYN vs Urology.
#
# Statistical tests performed:
#   1. Kruskal-Wallis: omnibus test of annual volume across specialty groups
#   2. Pairwise Wilcoxon (Bonferroni-corrected): post-hoc volume comparisons
#   3. Chi-square: proportion of low-volume surgeons across specialty groups
#   4. Linear regression on OB/GYN market-share trend (pct_slings_this_year)
#      with Cochran-Armitage-style interpretation
#
# Authors: Tyler Muffly, MD
# =============================================================================

source("R/reporting_stats_helpers.R")

# =============================================================================
# HELPER FUNCTIONS
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
fmt_n <- function(x) {
  format(round(x), big.mark = ",", scientific = FALSE)
}

#' @noRd
fmt_pct <- function(x, digits = 1) {
  sprintf(glue::glue("%.{digits}f%%"), x)
}

#' @noRd
fmt_p <- function(p_value) {
  assertthat::assert_that(
    is.numeric(p_value) && length(p_value) == 1L,
    msg = "fmt_p: p_value must be a single numeric."
  )
  # NA_real_ passes the is.numeric + length guard above, then
  # NA < 0.001 evaluates to NA in case_when, falling through to
  # sprintf("%.2f", NA) which silently returns "NA". Catch it explicitly.
  if (is.na(p_value)) return("NA (not computed)")
  dplyr::case_when(
    p_value < 0.001 ~ "<0.001",
    p_value < 0.01  ~ sprintf("%.3f", p_value),
    TRUE            ~ sprintf("%.2f",  p_value)
  )
}

#' @noRd
fmt_median_iqr <- function(volume_vector) {
  assertthat::assert_that(
    is.numeric(volume_vector),
    msg = "fmt_median_iqr: volume_vector must be numeric."
  )
  clean_values <- volume_vector[!is.na(volume_vector)]
  assertthat::assert_that(
    length(clean_values) > 0L,
    msg = "fmt_median_iqr: no non-NA values found."
  )
  quartiles  <- stats::quantile(clean_values, probs = c(0.25, 0.5, 0.75))
  glue::glue(
    "{round(quartiles[2])} (IQR {round(quartiles[1])}\u2013{round(quartiles[3])})"
  )
}

#' @noRd
pull_specialty_row <- function(specialty_summary_tbl, specialty_label) {
  row <- dplyr::filter(
    specialty_summary_tbl,
    specialty_group == specialty_label
  )
  assertthat::assert_that(
    nrow(row) == 1L,
    msg = glue::glue(
      "pull_specialty_row: expected exactly 1 row for '{specialty_label}', ",
      "got {nrow(row)}. Check specialty_summary contains this group."
    )
  )
  row
}

#' @noRd
pull_specialty_volumes <- function(provider_volume_tbl, specialty_label) {
  dplyr::filter(
    provider_volume_tbl,
    specialty_group == specialty_label
  ) |>
    dplyr::pull(annual_sling_count)
}

# =============================================================================
# STATISTICS HELPERS
# =============================================================================

#' @noRd
compute_kruskal_volume_test <- function(provider_volume_tbl, verbose = TRUE) {
  log_msg(
    "Computing Kruskal-Wallis test: annual volume across specialty groups.",
    verbose
  )
  kruskal_result <- stats::kruskal.test(
    annual_sling_count ~ specialty_group,
    data = provider_volume_tbl
  )
  log_msg(
    glue::glue(
      "  Kruskal-Wallis H = {round(kruskal_result$statistic, 2)}, ",
      "df = {kruskal_result$parameter}, ",
      "p {fmt_p(kruskal_result$p.value)}"
    ),
    verbose
  )
  kruskal_result
}

#' @noRd
compute_pairwise_volume_tests <- function(
    provider_volume_tbl,
    focal_groups = c("OB/GYN", "Urology"),
    verbose      = TRUE
) {
  log_msg(
    "Computing pairwise Wilcoxon tests (Bonferroni correction).",
    verbose
  )
  pairwise_result <- stats::pairwise.wilcox.test(
    x       = provider_volume_tbl$annual_sling_count,
    g       = provider_volume_tbl$specialty_group,
    p.adjust.method = "bonferroni",
    exact   = FALSE
  )

  # Extract focal pairwise p-values into a named list.
  #
  # pairwise.wilcox.test returns a lower-triangular matrix.
  # For a pair like (OB/GYN, Urology), try both orderings (a,b) and (b,a),
  # take the first scalar non-NA result. Coerce result to scalar and default
  # to NA_real_ if neither ordering yields a length-1 numeric.
  p_matrix    <- pairwise_result$p.value
  pair_list   <- list()
  focal_pairs <- utils::combn(focal_groups, 2, simplify = FALSE)

  extract_scalar_p <- function(p_mat, row_nm, col_nm) {
    if (
      !is.null(rownames(p_mat)) &&
      !is.null(colnames(p_mat)) &&
      row_nm %in% rownames(p_mat) &&
      col_nm %in% colnames(p_mat)
    ) {
      val <- p_mat[row_nm, col_nm]
      if (is.numeric(val) && length(val) == 1L) return(val)
    }
    NA_real_
  }

  for (pair in focal_pairs) {
    group_a   <- pair[1]
    group_b   <- pair[2]
    pair_name <- paste(group_a, "vs", group_b)

    p_val <- extract_scalar_p(p_matrix, group_a, group_b)
    if (is.na(p_val)) p_val <- extract_scalar_p(p_matrix, group_b, group_a)

    pair_list[[pair_name]] <- p_val
    log_msg(
      glue::glue("  {pair_name}: p {fmt_p(p_val)}"),
      verbose
    )
  }
  pair_list
}

#' @noRd
compute_low_volume_chisq <- function(
    provider_volume_tbl,
    low_volume_threshold,
    focal_groups = c("OB/GYN", "Urology"),
    verbose      = TRUE
) {
  log_msg(
    glue::glue(
      "Computing chi-square test: proportion low-volume (<{low_volume_threshold}/yr) ",
      "across focal specialty groups."
    ),
    verbose
  )
  npi_summary <- compute_provider_low_volume_status(
    provider_volume_tbl,
    low_volume_threshold = low_volume_threshold
  ) |>
    dplyr::filter(specialty_group %in% focal_groups)

  contingency_table <- table(
    npi_summary$specialty_group,
    npi_summary$is_low_volume_provider
  )

  # When all providers fall on the same side of the threshold the contingency
  # table has only one column. Return a mock htest with p.value = NA_real_ and
  # a diagnostic message so the abstract can still be generated with
  # appropriate "not computed" language in the chi-square sentence.
  if (ncol(contingency_table) < 2L) {
    log_msg(
      glue::glue(
        "  Chi-square skipped: all focal-group providers are on the same ",
        "side of the {low_volume_threshold}/yr threshold ",
        "(contingency table has only one column). p.value set to NA."
      ),
      verbose
    )
    na_htest <- structure(
      list(
        statistic  = stats::setNames(NA_real_, "X-squared"),
        parameter  = stats::setNames(NA_real_, "df"),
        p.value    = NA_real_,
        method     = "Chi-squared test (skipped: single-level table)",
        data.name  = "npi_summary"
      ),
      class = "htest"
    )
    return(na_htest)
  }

  chisq_result <- stats::chisq.test(contingency_table)
  log_msg(
    glue::glue(
      "  Chi-square X\u00b2 = {round(chisq_result$statistic, 2)}, ",
      "df = {chisq_result$parameter}, ",
      "p {fmt_p(chisq_result$p.value)}"
    ),
    verbose
  )
  chisq_result
}

#' @noRd
compute_obgyn_trend_test <- function(
    time_trends_tbl,
    year_col,
    verbose = TRUE
) {
  assertthat::assert_that(
    is.data.frame(time_trends_tbl),
    msg = "compute_obgyn_trend_test: time_trends_tbl must be a data frame."
  )
  assertthat::assert_that(
    "pct_slings_this_year" %in% names(time_trends_tbl),
    msg = paste0(
      "compute_obgyn_trend_test: pct_slings_this_year column not found. ",
      "Run analyze_midurethral_sling_patterns() with year_col set."
    )
  )
  log_msg(
    "Computing linear trend test: OB/GYN market share (pct_slings_this_year) ~ year.",
    verbose
  )
  obgyn_trend_rows <- dplyr::filter(
    time_trends_tbl,
    specialty_group == "OB/GYN"
  )
  if (nrow(obgyn_trend_rows) < 3L) {
    log_msg(
      paste0(
        "  OB/GYN trend test skipped: need at least 3 years of data; found ",
        nrow(obgyn_trend_rows), ". p.value set to NA."
      ),
      verbose
    )
    return(list(
      lm_object   = NULL,
      slope       = NA_real_,
      slope_p     = NA_real_,
      start_pct   = NA_real_,
      end_pct     = NA_real_,
      start_year  = NA_real_,
      end_year    = NA_real_,
      trend_phrase = NA_character_
    ))
  }
  year_values       <- obgyn_trend_rows[[year_col]]
  obgyn_pct_values  <- obgyn_trend_rows$pct_slings_this_year
  trend_lm          <- stats::lm(obgyn_pct_values ~ year_values)
  trend_summary     <- summary(trend_lm)
  slope             <- stats::coef(trend_lm)[["year_values"]]
  slope_p           <- trend_summary$coefficients["year_values", "Pr(>|t|)"]
  start_pct         <- dplyr::first(obgyn_pct_values[order(year_values)])
  end_pct           <- dplyr::last(obgyn_pct_values[order(year_values)])
  start_year        <- min(year_values)
  end_year          <- max(year_values)

  log_msg(
    glue::glue(
      "  OB/GYN share: {fmt_pct(start_pct)} ({start_year}) \u2192 ",
      "{fmt_pct(end_pct)} ({end_year}); ",
      "slope = {round(slope, 3)} pct-pts/yr, p {fmt_p(slope_p)}"
    ),
    verbose
  )

  list(
    lm_object   = trend_lm,
    slope       = slope,
    slope_p     = slope_p,
    start_pct   = start_pct,
    end_pct     = end_pct,
    start_year  = start_year,
    end_year    = end_year,
    # Adaptive direction phrase for abstract prose
    trend_phrase = dplyr::case_when(
      slope_p >= 0.05                 ~ "remained stable",
      slope > 0 & slope_p < 0.05     ~ "increased significantly",
      slope < 0 & slope_p < 0.05     ~ "decreased significantly",
      TRUE                            ~ "changed"
    )
  )
}


# =============================================================================
# ABSTRACT SECTION BUILDERS
# =============================================================================

#' @noRd
build_abstract_objective <- function() {
  paste0(
    "To characterize the specialty distribution and annual procedure volumes ",
    "of physicians performing midurethral sling procedures (CPT 57288) among ",
    "Medicare beneficiaries, and to quantify the proportion performed by ",
    "low-volume surgeons across specialty groups."
  )
}

#' @noRd
build_abstract_methods <- function(
    year_range,
    low_volume_threshold,
    include_trend_sentence
) {
  # Single-year = cross-sectional; multi-year with trend = repeated
  # cross-sectional. The distinction is driven by include_trend_sentence.
  trend_methods_sentence <- if (isTRUE(include_trend_sentence)) {
    paste0(
      "Time trends in OB/GYN procedure share were assessed by linear ",
      "regression of annual market-share percentage on calendar year."
    )
  } else {
    ""
  }

  study_design_label <- if (isTRUE(include_trend_sentence)) {
    "repeated cross-sectional"
  } else {
    "cross-sectional"
  }

  glue::glue(
    "We conducted a {study_design_label} analysis of the CMS Medicare ",
    "Physician and Other Practitioners Public Use File from {year_range[1]} ",
    "to {year_range[2]}. All providers billing CPT 57288 were identified and ",
    "classified into mutually exclusive specialty groups \u2014 obstetrics and ",
    "gynecology (OB/GYN), urology, and other \u2014 using a hierarchical taxonomy ",
    "applied to CMS-reported provider type. Annual sling volume was calculated ",
    "per provider per year. Low-volume surgeons were defined as those performing ",
    "fewer than {low_volume_threshold} procedures annually, consistent with ",
    "surgical quality literature. Descriptive statistics including median ",
    "annual volume with interquartile range (IQR) and the proportion of total ",
    "procedures attributable to low-volume surgeons were computed by specialty ",
    "group. An omnibus Kruskal-Wallis test assessed differences in annual ",
    "volume across specialty groups; pairwise comparisons used Wilcoxon ",
    "rank-sum tests with Bonferroni correction. Differences in the proportion ",
    "of low-volume surgeons across specialties were assessed by chi-square ",
    "test. {trend_methods_sentence}"
  )
}

#' @noRd
build_abstract_results <- function(
    specialty_summary_tbl,
    provider_volume_tbl,
    low_volume_burden_tbl,
    time_trends_tbl,
    year_col,
    low_volume_threshold,
    kruskal_result,
    pairwise_p_list,
    chisq_result,
    obgyn_trend,
    verbose = TRUE
) {
  # ── Pull key stats ────────────────────────────────────────────────────────
  grand_total_providers <- sum(specialty_summary_tbl$n_providers)
  grand_total_slings    <- sum(specialty_summary_tbl$total_slings)

  obgyn_row    <- pull_specialty_row(specialty_summary_tbl, "OB/GYN")
  urology_row  <- pull_specialty_row(specialty_summary_tbl, "Urology")

  obgyn_vols   <- pull_specialty_volumes(provider_volume_tbl, "OB/GYN")
  urology_vols <- pull_specialty_volumes(provider_volume_tbl, "Urology")

  # Low-volume burden: pct of ALL slings done by low-volume surgeons.
  # Use the column directly as the filter predicate (not isTRUE(), which
  # is scalar and would discard all rows).
  all_low_vol_slings <- dplyr::filter(
    low_volume_burden_tbl,
    is_low_volume_provider
  ) |>
    dplyr::pull(total_slings) |>
    sum(na.rm = TRUE)
  pct_slings_by_low_vol <- all_low_vol_slings / grand_total_slings * 100

  # Per-specialty low-volume pct
  obgyn_pct_low_vol   <- obgyn_row$pct_low_volume_providers
  urology_pct_low_vol <- urology_row$pct_low_volume_providers

  # Pairwise p-values — focal comparison is OB/GYN vs Urology
  p_obgyn_urology <- pairwise_p_list[["OB/GYN vs Urology"]]

  # Identify largest group by provider count from data (never hardcoded)
  largest_provider_group <- specialty_summary_tbl |>
    dplyr::arrange(dplyr::desc(n_providers)) |>
    dplyr::slice(1) |>
    dplyr::pull(specialty_group)

  largest_provider_row <- pull_specialty_row(
    specialty_summary_tbl, largest_provider_group
  )

  largest_group_label <- dplyr::case_when(
    largest_provider_group == "OB/GYN"  ~ "OB/GYN physicians",
    largest_provider_group == "Urology" ~ "urologists",
    TRUE ~ glue::glue("{largest_provider_group} providers")
  )

  largest_group_volumes <- pull_specialty_volumes(
    provider_volume_tbl, largest_provider_group
  )

  # Adaptive phrasing for OB/GYN vs Urology volume comparison
  volume_comparison_sentence <- if (
    !is.na(p_obgyn_urology) && p_obgyn_urology < 0.05
  ) {
    glue::glue(
      "Annual procedure volume differed significantly between OB/GYN ",
      "physicians and urologists (Wilcoxon p\u00a0{fmt_p(p_obgyn_urology)}, ",
      "Bonferroni-corrected). "
    )
  } else {
    glue::glue(
      "After Bonferroni correction, annual procedure volume did not differ ",
      "significantly between OB/GYN physicians and urologists ",
      "(p\u00a0{fmt_p(p_obgyn_urology)}). "
    )
  }

  log_msg(
    sprintf("[DEBUG] Results: grand_total_providers=%d, grand_total_slings=%d",
            grand_total_providers, grand_total_slings),
    verbose
  )

  # Kruskal-Wallis NA guard
  kruskal_phrasing <- if (!is.na(kruskal_result$p.value) &&
                          kruskal_result$p.value < 0.05) {
    glue::glue(
      "Annual sling volume differed significantly across specialty groups ",
      "(Kruskal-Wallis H\u00a0=\u00a0{round(kruskal_result$statistic, 1)}, ",
      "df\u00a0=\u00a0{kruskal_result$parameter}, ",
      "p\u00a0{fmt_p(kruskal_result$p.value)}). "
    )
  } else {
    glue::glue(
      "Annual sling volume did not differ significantly across specialty ",
      "groups (Kruskal-Wallis H\u00a0=\u00a0{round(kruskal_result$statistic, 1)}, ",
      "df\u00a0=\u00a0{kruskal_result$parameter}, ",
      "p\u00a0{fmt_p(kruskal_result$p.value)}). "
    )
  }

  # Chi-square phrasing with NA guard
  chisq_results_phrasing <- if (
    !is.na(chisq_result$p.value) && chisq_result$p.value < 0.05
  ) {
    glue::glue(
      "The proportion of low-volume surgeons (fewer than ",
      "{low_volume_threshold} procedures per year) differed significantly ",
      "across specialty groups ",
      "(\u03c7\u00b2\u00a0=\u00a0{round(chisq_result$statistic, 1)}, ",
      "df\u00a0=\u00a0{chisq_result$parameter}, ",
      "p\u00a0{fmt_p(chisq_result$p.value)}): "
    )
  } else {
    glue::glue(
      "The proportion of low-volume surgeons (fewer than ",
      "{low_volume_threshold} procedures per year) did not differ ",
      "significantly across specialty groups ",
      "(\u03c7\u00b2\u00a0=\u00a0{round(chisq_result$statistic, 1)}, ",
      "df\u00a0=\u00a0{chisq_result$parameter}, ",
      "p\u00a0{fmt_p(chisq_result$p.value)}): "
    )
  }

  # Suppress standalone urology sentence when Urology is already the largest
  # group (data already stated above).
  urology_sentence <- if (largest_provider_group != "Urology") {
    glue::glue(
      "Urologists accounted for {fmt_n(urology_row$n_providers)} providers ",
      "({fmt_pct(urology_row$pct_of_all_slings)} of procedures; ",
      "median {fmt_median_iqr(urology_vols)} procedures per year). "
    )
  } else {
    ""
  }

  # OB/GYN sentence: suppress when OB/GYN is the largest group (already stated)
  obgyn_sentence <- if (largest_provider_group != "OB/GYN") {
    glue::glue(
      "OB/GYN physicians accounted for {fmt_n(obgyn_row$n_providers)} providers ",
      "({fmt_pct(obgyn_row$pct_of_all_slings)} of procedures; ",
      "median {fmt_median_iqr(obgyn_vols)} procedures per year). "
    )
  } else {
    ""
  }

  # Trend sentence — suppressed when slope_p is NA
  trend_sentence <- if (!is.null(obgyn_trend) && !is.na(obgyn_trend$slope_p)) {
    glue::glue(
      "Over the study period, the proportion of procedures performed by ",
      "OB/GYN physicians {obgyn_trend$trend_phrase} from ",
      "{fmt_pct(obgyn_trend$start_pct)} in {obgyn_trend$start_year} to ",
      "{fmt_pct(obgyn_trend$end_pct)} in {obgyn_trend$end_year} ",
      "(slope = {round(obgyn_trend$slope, 2)} percentage points per year; ",
      "p {fmt_p(obgyn_trend$slope_p)})."
    )
  } else {
    ""
  }

  # ── Compose paragraph ─────────────────────────────────────────────────────
  glue::glue(
    "A total of {fmt_n(grand_total_providers)} unique providers billed ",
    "CPT 57288 across the study period, accounting for ",
    "{fmt_n(grand_total_slings)} procedures. ",

    "OB/GYN physicians represented the largest group, accounting for ",
    "{fmt_pct(obgyn_row$pct_of_all_slings)} of all procedures at a median ",
    "annual volume of {fmt_median_iqr(obgyn_vols)} procedures per year ",
    "({fmt_n(obgyn_row$n_providers)} providers). ",

    "{urology_sentence}",

    "{obgyn_sentence}",

    "{kruskal_phrasing}",

    "{volume_comparison_sentence}",

    "{chisq_results_phrasing}",
    "{fmt_pct(obgyn_pct_low_vol)} of OB/GYN physicians and ",
    "{fmt_pct(urology_pct_low_vol)} of urologists were classified as ",
    "low-volume. ",

    "Low-volume surgeons across all specialties collectively accounted for ",
    "{fmt_pct(pct_slings_by_low_vol)} of all midurethral sling procedures. ",

    "{trend_sentence}"
  )
}

#' @noRd
build_abstract_conclusions <- function(
    specialty_summary_tbl,
    low_volume_threshold,
    obgyn_trend,
    chisq_p
) {
  # Adaptive phrasing: who performs the most procedures by total share?
  dominant_specialty <- specialty_summary_tbl |>
    dplyr::arrange(dplyr::desc(total_slings)) |>
    dplyr::slice(1) |>
    dplyr::pull(specialty_group)

  dominance_phrase <- if (dominant_specialty == "OB/GYN") {
    "OB/GYN physicians perform the greatest share of midurethral sling procedures in Medicare"
  } else {
    glue::glue(
      "a substantial proportion of midurethral sling procedures are performed ",
      "by {dominant_specialty} physicians"
    )
  }

  # Trend conclusion — NA guard mirrors build_abstract_results logic
  trend_conclusion <- if (
    !is.null(obgyn_trend) &&
    !is.na(obgyn_trend$slope_p) &&
    obgyn_trend$slope_p < 0.05
  ) {
    glue::glue(
      " OB/GYN procedure share {obgyn_trend$trend_phrase} over the ",
      "study period, suggesting {if (obgyn_trend$slope > 0) ",
      "'growing scope-of-practice expansion by generalist physicians' else ",
      "'a shifting procedural landscape with potential workforce implications'}."
    )
  } else {
    ""
  }

  # Chi-square significance phrase with NA guard
  chisq_significance_phrase <- if (!is.na(chisq_p) && chisq_p < 0.05) {
    glue::glue(
      "The significant difference in the proportion of low-volume surgeons ",
      "across specialty groups (p\u00a0{fmt_p(chisq_p)}) highlights heterogeneity"
    )
  } else {
    glue::glue(
      "Although the difference in the proportion of low-volume surgeons ",
      "across specialty groups did not reach statistical significance ",
      "(p\u00a0{fmt_p(chisq_p)}), the observed pattern highlights heterogeneity"
    )
  }

  glue::glue(
    "In this national Medicare cohort, {dominance_phrase}; however, ",
    "a substantial proportion of providers performing this procedure operate ",
    "at low annual volumes (fewer than {low_volume_threshold} cases per year). ",
    "{chisq_significance_phrase} in ",
    "procedural concentration that is not apparent from provider counts alone.",
    "{trend_conclusion} ",
    "These findings have implications for surgical training requirements, ",
    "credentialing standards, and equitable access to high-quality pelvic ",
    "floor surgical care."
  )
}


# =============================================================================
# MAIN EXPORTED FUNCTION
# =============================================================================

#' Generate a Programmatically Filled Abstract for the Midurethral Sling Study
#'
#' @description
#' Accepts the named list returned by
#' \code{\link{analyze_midurethral_sling_patterns}()} and computes all
#' statistics and p-values required to render a complete, publication-ready
#' structured abstract. Every number, percentage, IQR, p-value, and
#' directional phrase is derived programmatically from the data. The CMS
#' Medicare PUF does not include an FPMRS (urogynecology) provider type;
#' the three groups present in the data are OB/GYN, Urology, and Other.
#' The focal comparison is OB/GYN vs Urology.
#'
#' @details
#' ## Statistical Tests (performed in order)
#' \enumerate{
#'   \item \strong{Kruskal-Wallis} omnibus test of annual procedure volume
#'     across all specialty groups. Non-parametric because sling volumes are
#'     heavily right-skewed. Reports H statistic, df, and p-value.
#'   \item \strong{Pairwise Wilcoxon rank-sum} tests with Bonferroni
#'     correction for focal comparisons. With three groups the pairwise
#'     matrix covers OB/GYN vs Urology, OB/GYN vs Other, and
#'     Urology vs Other. The OB/GYN vs Urology p-value is reported in
#'     the abstract.
#'   \item \strong{Chi-square} test of independence for the proportion of
#'     low-volume surgeons across OB/GYN and Urology. When all providers
#'     fall on the same side of the threshold (i.e., the contingency table
#'     has only one level), the test is skipped and
#'     \code{p.value = NA} is returned rather than stopping with an error.
#'   \item \strong{Linear regression} of OB/GYN annual market share
#'     (\code{pct_slings_this_year}) on calendar year. Yields a slope
#'     in percentage-points per year and a two-sided t-test p-value.
#'     Only computed when \code{year_col} is non-\code{NULL} and at
#'     least three years of OB/GYN data are present.
#' }
#'
#' ## Adaptive Abstract Wording
#' Several sentences are generated conditionally to match the data:
#' \itemize{
#'   \item \strong{Trend phrase}: "increased significantly" /
#'     "decreased significantly" / "remained stable" — based on the sign
#'     and significance (p < 0.05) of the linear regression slope.
#'     The trend sentence is fully suppressed when the slope p-value is
#'     \code{NA} (e.g., fewer than 3 years of data).
#'   \item \strong{Largest provider group}: the group with the most
#'     providers is identified from data, never hardcoded.
#'   \item \strong{Volume comparison}: two branches depending on whether
#'     the OB/GYN vs Urology pairwise comparison is significant after
#'     Bonferroni correction.
#'   \item \strong{Conclusions dominance}: adapts based on whether OB/GYN
#'     or another specialty accounts for the greatest total procedure share.
#'   \item \strong{Kruskal-Wallis phrasing}: "differed significantly" vs
#'     "did not differ significantly" based on p < 0.05.
#'   \item \strong{Chi-square phrasing}: applies in both the Results and
#'     Conclusions sections independently.
#' }
#'
#' ## Audit Trail
#' Every scalar interpolated into the abstract is captured in
#' \code{filled_values}. If a reviewer asks "where does 66.5% come from?",
#' the answer is \code{filled_values$obgyn_pct_of_all_slings}.
#'
#' @param sling_analysis_output Named list returned by
#'   \code{\link{analyze_midurethral_sling_patterns}()}. Must contain the
#'   four elements \code{provider_volume}, \code{specialty_summary},
#'   \code{low_volume_burden}, and \code{time_trends} (\code{NULL} is
#'   acceptable for the last element when no year column was used).
#' @param year_col Character string or \code{NULL}. Must match the
#'   \code{year_col} argument passed to
#'   \code{\link{analyze_midurethral_sling_patterns}()}. Required to
#'   locate the year column in \code{time_trends} and to trigger the
#'   linear trend test. Pass \code{NULL} for a cross-sectional abstract
#'   (trend sentence omitted, Methods reads "cross-sectional analysis").
#' @param low_volume_threshold Single positive number. Must match the
#'   value used in \code{\link{analyze_midurethral_sling_patterns}()} so
#'   that the abstract prose ("fewer than X procedures per year") agrees
#'   with the computed statistics. Default \code{10L}. Common sensitivity
#'   alternatives: \code{5L} (strict) or \code{25L} (lenient).
#' @param study_years Integer vector of length exactly 2,
#'   \code{c(start_year, end_year)}, with \code{start_year <=
#'   end_year}. Used to populate the Methods section ("from YYYY to YYYY").
#'   When \code{NULL} and \code{year_col} is non-\code{NULL}, the range
#'   is inferred from the minimum and maximum values in \code{time_trends}.
#'   When both are \code{NULL}, defaults to \code{c(2017L, 2023L)}.
#' @param verbose Logical scalar. When \code{TRUE} (the default),
#'   timestamped progress messages are written to the console at each
#'   internal step. Set to \code{FALSE} for silent batch operation.
#'
#' @return A named list with three elements:
#' \describe{
#'   \item{\code{abstract_text}}{Single character string. The complete
#'     structured abstract with four sections separated by
#'     \code{"\\n\\n"}: OBJECTIVE, METHODS, RESULTS, CONCLUSIONS.}
#'   \item{\code{stats_table}}{Tibble with one row per statistical test.
#'     Columns: \code{test}, \code{statistic}, \code{df}, \code{p_value},
#'     \code{p_formatted}.}
#'   \item{\code{filled_values}}{Named list of scalars corresponding to
#'     every number, percentage, and directional phrase interpolated into
#'     the abstract text.}
#' }
#'
#' @note
#' \code{low_volume_threshold} must be identical here and in
#' \code{\link{analyze_midurethral_sling_patterns}()} so that the
#' abstract prose agrees with the underlying statistics.
#'
#' @seealso
#' \code{\link{analyze_midurethral_sling_patterns}()} for the upstream
#' analysis function whose output this function consumes.
#'
#' @author Tyler Muffly, MD
#'
#' @references
#' Centers for Medicare & Medicaid Services. Medicare Physician & Other
#' Practitioners Public Use File, calendar years 2017–2023.
#' \url{https://data.cms.gov}
#'
#' @family sling pipeline
#'
#' @examples
#' # ----------------------------------------------------------------
#' # Example 1 — Cross-sectional abstract (single year, no trend test)
#' # Methods will read "cross-sectional analysis"; trend sentence omitted.
#' # ----------------------------------------------------------------
#' \donttest{
#' synthetic_puf <- tibble::tibble(
#'   Rndrng_NPI        = as.character(1001:1016),
#'   Rndrng_Prvdr_Type = c(
#'     rep("Obstetrics & Gynecology", 6),
#'     rep("Urology",                 4),
#'     rep("Internal Medicine",       1),
#'     rep("Obstetrics & Gynecology", 3),
#'     rep("Urology",                 2)
#'   ),
#'   HCPCS_Cd  = "57288",
#'   Tot_Srvcs = c(
#'     5L,  4L,  7L,  3L,  6L, 8L,   # OB/GYN — all < 10
#'     12L, 15L, 9L, 18L,             # Urology — mixed
#'     2L,                            # Other
#'     22L, 18L, 30L,                 # OB/GYN — high
#'     11L, 14L                       # Urology — high
#'   )
#' )
#' pipeline_cs <- analyze_midurethral_sling_patterns(
#'   medicare_puf_data    = synthetic_puf,
#'   year_col             = NULL,
#'   low_volume_threshold = 10L,
#'   verbose              = FALSE
#' )
#' abstract_cs <- generate_sling_abstract(
#'   sling_analysis_output = pipeline_cs,
#'   year_col              = NULL,
#'   low_volume_threshold  = 10L,
#'   study_years           = c(2017L, 2023L),
#'   verbose               = FALSE
#' )
#' cat(abstract_cs$abstract_text)
#' print(abstract_cs$stats_table)
#' }
#'
#' # ----------------------------------------------------------------
#' # Example 2 — Multi-year abstract with linear trend test
#' # ----------------------------------------------------------------
#' \donttest{
#' synthetic_puf_trend <- tibble::tibble(
#'   Rndrng_NPI        = rep(as.character(1001:1012), times = 3),
#'   Rndrng_Prvdr_Type = rep(c(
#'     rep("Obstetrics & Gynecology", 5),
#'     rep("Urology",                 3),
#'     rep("Internal Medicine",       1),
#'     rep("Obstetrics & Gynecology", 2),
#'     rep("Urology",                 1)
#'   ), times = 3),
#'   HCPCS_Cd  = "57288",
#'   Tot_Srvcs = c(
#'     5L, 4L, 7L, 3L, 6L, 12L, 9L, 14L, 2L, 22L, 18L, 11L,
#'     6L, 5L, 8L, 4L, 7L, 14L, 10L, 16L, 3L, 24L, 20L, 13L,
#'     7L, 6L, 9L, 5L, 8L, 15L, 11L, 18L, 4L, 26L, 22L, 15L
#'   ),
#'   year = rep(2021L:2023L, each = 12L)
#' )
#' pipeline_trend <- analyze_midurethral_sling_patterns(
#'   medicare_puf_data    = synthetic_puf_trend,
#'   year_col             = "year",
#'   low_volume_threshold = 10L,
#'   verbose              = FALSE
#' )
#' abstract_trend <- generate_sling_abstract(
#'   sling_analysis_output = pipeline_trend,
#'   year_col              = "year",
#'   low_volume_threshold  = 10L,
#'   study_years           = NULL,
#'   verbose               = FALSE
#' )
#' cat(abstract_trend$abstract_text)
#' }
#'
#' @importFrom dplyr filter arrange desc slice pull group_by summarise
#'   bind_rows mutate case_when first last n_distinct distinct across
#'   all_of ungroup
#' @importFrom rlang sym
#' @importFrom glue glue
#' @importFrom assertthat assert_that
#' @importFrom stats kruskal.test pairwise.wilcox.test chisq.test
#'   quantile lm coef summary.lm
#' @importFrom tibble tibble
#' @importFrom purrr map set_names iwalk walk
#' @importFrom utils combn
#'
#' @export
generate_sling_abstract <- function(
    sling_analysis_output,
    year_col             = NULL,
    low_volume_threshold = 10L,
    study_years          = NULL,
    verbose              = TRUE
) {
  # ── 0. Validate inputs ────────────────────────────────────────────────────
  assertthat::assert_that(
    is.logical(verbose) && length(verbose) == 1L,
    msg = "verbose must be a single TRUE or FALSE."
  )
  log_msg("== generate_sling_abstract: START ==", verbose)

  assertthat::assert_that(
    is.numeric(low_volume_threshold) && length(low_volume_threshold) == 1L &&
      low_volume_threshold > 0,
    msg = "low_volume_threshold must be a single positive number."
  )

  if (!is.null(study_years)) {
    assertthat::assert_that(
      is.numeric(study_years) && length(study_years) == 2L,
      msg = "study_years must be a numeric vector of exactly 2 elements: c(start_year, end_year)."
    )
    assertthat::assert_that(
      study_years[1] <= study_years[2],
      msg = glue::glue(
        "study_years[1] ({study_years[1]}) must be <= study_years[2] ({study_years[2]}). ",
        "Pass the earlier year first."
      )
    )
  }

  provider_volume_tbl   <- sling_analysis_output$provider_volume
  specialty_summary_tbl <- sling_analysis_output$specialty_summary
  low_volume_burden_tbl <- sling_analysis_output$low_volume_burden
  time_trends_tbl       <- sling_analysis_output$time_trends

  validate_reporting_analysis_output(
    sling_analysis_output,
    year_col = year_col,
    required_specialty_groups = c("OB/GYN", "Urology")
  )
  present_groups <- unique(specialty_summary_tbl$specialty_group)
  log_msg(
    sprintf("[DEBUG] specialty groups present: %s",
            paste(present_groups, collapse = ", ")),
    verbose
  )

  # Infer study_years from time_trends if not supplied
  if (is.null(study_years) && !is.null(time_trends_tbl) &&
      !is.null(year_col)) {
    year_values_all <- time_trends_tbl[[year_col]]
    study_years     <- c(min(year_values_all), max(year_values_all))
    log_msg(
      glue::glue(
        "study_years inferred from time_trends: ",
        "{study_years[1]}\u2013{study_years[2]}"
      ),
      verbose
    )
  } else if (is.null(study_years)) {
    study_years <- c(2017L, 2023L)
    log_msg(
      "study_years not supplied and no time_trends available; defaulting to 2017\u20132023.",
      verbose
    )
  }

  log_msg(
    glue::glue(
      "Inputs \u2014 study_years: {study_years[1]}\u2013{study_years[2]}, ",
      "low_volume_threshold: {low_volume_threshold}, ",
      "year_col: {if (is.null(year_col)) 'NULL' else year_col}, ",
      "provider_volume rows: {nrow(provider_volume_tbl)}"
    ),
    verbose
  )

  # ── 1. Statistical tests ──────────────────────────────────────────────────
  log_msg("Step 1 - Running statistical tests.", verbose)

  kruskal_result  <- compute_kruskal_volume_test(
    provider_volume_tbl, verbose = verbose
  )
  pairwise_p_list <- compute_pairwise_volume_tests(
    provider_volume_tbl,
    focal_groups = c("OB/GYN", "Urology"),
    verbose      = verbose
  )
  chisq_result    <- compute_low_volume_chisq(
    provider_volume_tbl,
    low_volume_threshold = low_volume_threshold,
    focal_groups         = c("OB/GYN", "Urology"),
    verbose              = verbose
  )

  obgyn_trend <- if (!is.null(time_trends_tbl) && !is.null(year_col)) {
    compute_obgyn_trend_test(time_trends_tbl, year_col, verbose = verbose)
  } else {
    log_msg("Step 1 - Trend test skipped (year_col = NULL).", verbose)
    NULL
  }

  # ── 2. Build stats table ──────────────────────────────────────────────────
  log_msg("Step 2 - Assembling stats_table.", verbose)
  stats_table <- build_focal_stats_table(
    provider_volume_tbl,
    low_volume_threshold = low_volume_threshold,
    focal_groups = c("OB/GYN", "Urology"),
    time_trends_tbl = time_trends_tbl,
    year_col = year_col
  )
  log_msg(
    glue::glue("  stats_table: {nrow(stats_table)} rows"),
    verbose
  )

  # ── 3. Build abstract sections ────────────────────────────────────────────
  log_msg("Step 3 - Building abstract sections.", verbose)

  objective_text   <- build_abstract_objective()
  methods_text     <- build_abstract_methods(
    study_years,
    low_volume_threshold,
    include_trend_sentence = !is.null(year_col)
  )
  results_text     <- build_abstract_results(
    specialty_summary_tbl = specialty_summary_tbl,
    provider_volume_tbl   = provider_volume_tbl,
    low_volume_burden_tbl = low_volume_burden_tbl,
    time_trends_tbl       = time_trends_tbl,
    year_col              = year_col,
    low_volume_threshold  = low_volume_threshold,
    kruskal_result        = kruskal_result,
    pairwise_p_list       = pairwise_p_list,
    chisq_result          = chisq_result,
    obgyn_trend           = obgyn_trend,
    verbose               = verbose
  )
  conclusions_text <- build_abstract_conclusions(
    specialty_summary_tbl = specialty_summary_tbl,
    low_volume_threshold  = low_volume_threshold,
    obgyn_trend           = obgyn_trend,
    chisq_p               = chisq_result$p.value
  )

  abstract_text <- paste0(
    "OBJECTIVE\n", objective_text,   "\n\n",
    "METHODS\n",   methods_text,     "\n\n",
    "RESULTS\n",   results_text,     "\n\n",
    "CONCLUSIONS\n", conclusions_text
  )

  # ── 4. Capture filled values for audit ───────────────────────────────────
  obgyn_row   <- pull_specialty_row(specialty_summary_tbl, "OB/GYN")
  urology_row <- pull_specialty_row(specialty_summary_tbl, "Urology")

  filled_values <- list(
    grand_total_providers      = sum(specialty_summary_tbl$n_providers),
    grand_total_slings         = sum(specialty_summary_tbl$total_slings),
    obgyn_n_providers          = obgyn_row$n_providers,
    obgyn_pct_of_all_slings    = obgyn_row$pct_of_all_slings,
    obgyn_median_iqr           = fmt_median_iqr(
      pull_specialty_volumes(provider_volume_tbl, "OB/GYN")
    ),
    obgyn_pct_low_volume       = obgyn_row$pct_low_volume_providers,
    urology_n_providers        = urology_row$n_providers,
    urology_pct_of_all_slings  = urology_row$pct_of_all_slings,
    urology_median_iqr         = fmt_median_iqr(
      pull_specialty_volumes(provider_volume_tbl, "Urology")
    ),
    urology_pct_low_volume     = urology_row$pct_low_volume_providers,
    kruskal_h                  = as.numeric(kruskal_result$statistic),
    kruskal_p                  = kruskal_result$p.value,
    chisq_stat                 = as.numeric(chisq_result$statistic),
    chisq_p                    = chisq_result$p.value,
    p_obgyn_vs_urology         = pairwise_p_list[["OB/GYN vs Urology"]],
    obgyn_trend_slope          = if (!is.null(obgyn_trend)) obgyn_trend$slope       else NA_real_,
    obgyn_trend_p              = if (!is.null(obgyn_trend)) obgyn_trend$slope_p     else NA_real_,
    obgyn_trend_phrase         = if (!is.null(obgyn_trend)) obgyn_trend$trend_phrase else NA_character_,
    obgyn_start_pct            = if (!is.null(obgyn_trend)) obgyn_trend$start_pct   else NA_real_,
    obgyn_end_pct              = if (!is.null(obgyn_trend)) obgyn_trend$end_pct     else NA_real_
  )

  # ── 5. Log output ─────────────────────────────────────────────────────────
  # Compute word count outside glue to avoid escape-sequence bugs.
  abstract_word_count <- length(strsplit(abstract_text, "\\s+")[[1]])
  log_msg("-- Output summary --", verbose)
  log_msg(
    glue::glue(
      "  abstract_text: {nchar(abstract_text)} characters, ",
      "{abstract_word_count} words"
    ),
    verbose
  )
  log_msg(
    glue::glue("  stats_table: {nrow(stats_table)} tests"),
    verbose
  )
  log_msg(
    glue::glue(
      "  filled_values: {length(filled_values)} scalars audited"
    ),
    verbose
  )
  log_msg("== generate_sling_abstract: COMPLETE ==", verbose)

  list(
    abstract_text = abstract_text,
    stats_table   = stats_table,
    filled_values = filled_values
  )
}
