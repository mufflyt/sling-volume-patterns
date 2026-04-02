# =============================================================================
# reporting_stats_helpers.R
#
# Shared helpers for provider-level low-volume classification and
# publication-reporting statistical summaries.
#
# Authors: Tyler Muffly, MD
# =============================================================================

#' @noRd
assert_required_columns <- function(data, required_columns, object_name) {
  assertthat::assert_that(
    is.data.frame(data),
    msg = glue::glue("{object_name} must be a data frame or tibble.")
  )
  missing_columns <- setdiff(required_columns, names(data))
  assertthat::assert_that(
    length(missing_columns) == 0L,
    msg = glue::glue(
      "{object_name} is missing required columns: ",
      "{paste(missing_columns, collapse = ', ')}"
    )
  )
  invisible(TRUE)
}

#' @noRd
validate_reporting_analysis_output <- function(
    sling_analysis_output,
    year_col = NULL,
    required_specialty_groups = character(0)
) {
  assertthat::assert_that(
    is.list(sling_analysis_output),
    msg = paste0(
      "sling_analysis_output must be a named list ",
      "(output of analyze_midurethral_sling_patterns)."
    )
  )

  required_elements <- c(
    "provider_volume", "specialty_summary",
    "low_volume_burden", "time_trends"
  )
  missing_elements <- setdiff(required_elements, names(sling_analysis_output))
  assertthat::assert_that(
    length(missing_elements) == 0L,
    msg = glue::glue(
      "sling_analysis_output is missing required elements: ",
      "{paste(missing_elements, collapse = ', ')}"
    )
  )

  provider_volume_tbl   <- sling_analysis_output$provider_volume
  specialty_summary_tbl <- sling_analysis_output$specialty_summary
  low_volume_burden_tbl <- sling_analysis_output$low_volume_burden
  time_trends_tbl       <- sling_analysis_output$time_trends

  provider_volume_cols <- c(
    "Rndrng_NPI", "specialty_group", "annual_sling_count", "volume_tier"
  )
  if (!is.null(year_col)) {
    provider_volume_cols <- c(provider_volume_cols, year_col)
  }
  assert_required_columns(
    provider_volume_tbl,
    provider_volume_cols,
    "provider_volume"
  )
  assert_required_columns(
    specialty_summary_tbl,
    c(
      "specialty_group", "n_providers", "total_slings",
      "median_annual_volume", "mean_annual_volume",
      "n_low_volume_providers", "pct_low_volume_providers",
      "pct_of_all_slings"
    ),
    "specialty_summary"
  )
  assert_required_columns(
    low_volume_burden_tbl,
    c(
      "specialty_group", "is_low_volume_provider",
      "n_providers", "total_slings", "pct_of_all_slings"
    ),
    "low_volume_burden"
  )

  if (is.null(time_trends_tbl)) {
    assertthat::assert_that(
      is.null(year_col),
      msg = paste0(
        "time_trends is NULL but year_col was supplied. ",
        "Reporting helpers require time_trends when year_col is non-NULL."
      )
    )
  } else {
    time_trends_cols <- c(
      "specialty_group", "total_slings",
      "n_providers", "median_annual_volume", "pct_slings_this_year"
    )
    if (!is.null(year_col)) {
      time_trends_cols <- c(time_trends_cols, year_col)
    }
    assert_required_columns(
      time_trends_tbl,
      time_trends_cols,
      "time_trends"
    )
  }

  if (length(required_specialty_groups) > 0L) {
    present_groups <- unique(specialty_summary_tbl$specialty_group)
    missing_groups <- setdiff(required_specialty_groups, present_groups)
    assertthat::assert_that(
      length(missing_groups) == 0L,
      msg = glue::glue(
        "Missing required specialty groups in specialty_summary: ",
        "{paste(missing_groups, collapse = ', ')}. Present groups: ",
        "{paste(present_groups, collapse = ', ')}"
      )
    )
  }

  invisible(TRUE)
}

#' @noRd
compute_provider_low_volume_status <- function(
    provider_volume_data,
    low_volume_threshold
) {
  assertthat::assert_that(
    is.data.frame(provider_volume_data),
    msg = "compute_provider_low_volume_status: provider_volume_data must be a data frame."
  )
  required_columns <- c("Rndrng_NPI", "specialty_group", "annual_sling_count")
  missing_columns <- setdiff(required_columns, names(provider_volume_data))
  assertthat::assert_that(
    length(missing_columns) == 0L,
    msg = glue::glue(
      "compute_provider_low_volume_status: missing required columns: ",
      "{paste(missing_columns, collapse = ', ')}"
    )
  )
  assertthat::assert_that(
    is.numeric(low_volume_threshold) &&
      length(low_volume_threshold) == 1L &&
      low_volume_threshold > 0,
    msg = paste0(
      "compute_provider_low_volume_status: low_volume_threshold must be a ",
      "single positive number."
    )
  )

  provider_volume_data |>
    dplyr::group_by(Rndrng_NPI, specialty_group) |>
    dplyr::summarise(
      mean_annual_sling_count = mean(annual_sling_count, na.rm = TRUE),
      total_slings_all_years  = sum(annual_sling_count, na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      is_low_volume_provider = mean_annual_sling_count < low_volume_threshold
    )
}

#' @noRd
safe_pairwise_wilcox_tidy <- function(
    provider_volume_data,
    focal_groups = c("OB/GYN", "Urology"),
    p_adjust_method = "bonferroni"
) {
  comparison_label <- paste(focal_groups, collapse = " vs ")
  focal_volume <- dplyr::filter(
    provider_volume_data,
    specialty_group %in% focal_groups
  )
  present_groups <- intersect(focal_groups, unique(focal_volume$specialty_group))

  if (length(present_groups) < 2L) {
    return(tibble::tibble(
      statistic  = NA_real_,
      parameter  = NA_real_,
      p.value    = NA_real_,
      comparison = comparison_label,
      test       = "Wilcoxon rank-sum (Bonferroni; not computed)"
    ))
  }

  pairwise_result <- stats::pairwise.wilcox.test(
    x               = focal_volume$annual_sling_count,
    g               = focal_volume$specialty_group,
    p.adjust.method = p_adjust_method,
    exact           = FALSE
  )

  tidy_result <- tryCatch(
    broom::tidy(pairwise_result),
    error = function(e) tibble::tibble()
  )

  if (
    nrow(tidy_result) == 0L ||
      !all(c("group1", "group2", "p.value") %in% names(tidy_result))
  ) {
    return(tibble::tibble(
      statistic  = NA_real_,
      parameter  = NA_real_,
      p.value    = NA_real_,
      comparison = comparison_label,
      test       = "Wilcoxon rank-sum (Bonferroni; not computed)"
    ))
  }

  tidy_result |>
    dplyr::transmute(
      statistic  = NA_real_,
      parameter  = NA_real_,
      p.value    = p.value,
      comparison = paste(group1, "vs", group2),
      test       = "Wilcoxon rank-sum (Bonferroni)"
    )
}

#' @noRd
safe_low_volume_chisq_tidy <- function(
    provider_volume_data,
    low_volume_threshold,
    focal_groups = c("OB/GYN", "Urology")
) {
  comparison_label <- paste(focal_groups, collapse = " vs ")
  npi_summary <- compute_provider_low_volume_status(
    provider_volume_data,
    low_volume_threshold = low_volume_threshold
  ) |>
    dplyr::filter(specialty_group %in% focal_groups)

  present_groups <- intersect(focal_groups, unique(npi_summary$specialty_group))
  if (length(present_groups) < 2L) {
    return(tibble::tibble(
      statistic  = NA_real_,
      parameter  = NA_real_,
      p.value    = NA_real_,
      comparison = comparison_label,
      test       = "Chi-square (not computed)"
    ))
  }

  contingency_table <- table(
    npi_summary$specialty_group,
    npi_summary$is_low_volume_provider
  )

  if (nrow(contingency_table) < 2L || ncol(contingency_table) < 2L) {
    return(tibble::tibble(
      statistic  = NA_real_,
      parameter  = NA_real_,
      p.value    = NA_real_,
      comparison = comparison_label,
      test       = "Chi-square (not computed)"
    ))
  }

  stats::chisq.test(contingency_table) |>
    broom::tidy() |>
    dplyr::transmute(
      statistic  = statistic,
      parameter  = parameter,
      p.value    = p.value,
      comparison = comparison_label,
      test       = "Chi-square"
    )
}

#' @noRd
safe_obgyn_trend_row <- function(time_trends_tbl, year_col) {
  if (is.null(time_trends_tbl) || is.null(year_col)) {
    return(tibble::tibble(
      test        = character(0),
      statistic   = numeric(0),
      df          = numeric(0),
      p_value     = numeric(0),
      p_formatted = character(0)
    ))
  }

  assert_required_columns(
    time_trends_tbl,
    c(year_col, "specialty_group", "pct_slings_this_year"),
    "time_trends"
  )

  obgyn_trend_rows <- dplyr::filter(
    time_trends_tbl,
    specialty_group == "OB/GYN"
  )
  if (nrow(obgyn_trend_rows) < 3L) {
    return(tibble::tibble(
      test        = "Linear regression: OB/GYN market share ~ year",
      statistic   = NA_real_,
      df          = NA_real_,
      p_value     = NA_real_,
      p_formatted = "NA (not computed)"
    ))
  }

  year_values      <- obgyn_trend_rows[[year_col]]
  obgyn_pct_values <- obgyn_trend_rows$pct_slings_this_year
  trend_lm         <- stats::lm(obgyn_pct_values ~ year_values)
  trend_summary    <- summary(trend_lm)
  slope            <- stats::coef(trend_lm)[["year_values"]]
  slope_p          <- trend_summary$coefficients["year_values", "Pr(>|t|)"]

  tibble::tibble(
    test        = "Linear regression: OB/GYN market share ~ year",
    statistic   = slope,
    df          = NA_real_,
    p_value     = slope_p,
    p_formatted = dplyr::case_when(
      is.na(slope_p)  ~ "NA (not computed)",
      slope_p < 0.001 ~ "<0.001",
      slope_p < 0.01  ~ sprintf("%.3f", slope_p),
      TRUE            ~ sprintf("%.2f", slope_p)
    )
  )
}

#' @noRd
build_focal_stats_table <- function(
    provider_volume_data,
    low_volume_threshold,
    focal_groups = c("OB/GYN", "Urology"),
    time_trends_tbl = NULL,
    year_col = NULL
) {
  assert_required_columns(
    provider_volume_data,
    c("annual_sling_count", "specialty_group"),
    "provider_volume"
  )

  kruskal_tidy <- stats::kruskal.test(
    annual_sling_count ~ specialty_group,
    data = provider_volume_data
  ) |>
    broom::tidy() |>
    dplyr::transmute(
      test        = "Kruskal-Wallis: annual volume across specialty groups",
      statistic   = statistic,
      df          = parameter,
      p_value     = p.value,
      p_formatted = dplyr::case_when(
        is.na(p.value)  ~ "NA (not computed)",
        p.value < 0.001 ~ "<0.001",
        p.value < 0.01  ~ sprintf("%.3f", p.value),
        TRUE            ~ sprintf("%.2f", p.value)
      )
    )

  pairwise_rows <- safe_pairwise_wilcox_tidy(
    provider_volume_data,
    focal_groups = focal_groups,
    p_adjust_method = "bonferroni"
  ) |>
    dplyr::transmute(
      test        = glue::glue("Wilcoxon (Bonferroni): {comparison}"),
      statistic   = statistic,
      df          = parameter,
      p_value     = p.value,
      p_formatted = dplyr::case_when(
        is.na(p.value)  ~ "NA (not computed)",
        p.value < 0.001 ~ "<0.001",
        p.value < 0.01  ~ sprintf("%.3f", p.value),
        TRUE            ~ sprintf("%.2f", p.value)
      )
    )

  chisq_row <- safe_low_volume_chisq_tidy(
    provider_volume_data,
    low_volume_threshold = low_volume_threshold,
    focal_groups = focal_groups
  ) |>
    dplyr::transmute(
      test        = "Chi-square: proportion low-volume across specialties",
      statistic   = statistic,
      df          = parameter,
      p_value     = p.value,
      p_formatted = dplyr::case_when(
        is.na(p.value)  ~ "NA (not computed)",
        p.value < 0.001 ~ "<0.001",
        p.value < 0.01  ~ sprintf("%.3f", p.value),
        TRUE            ~ sprintf("%.2f", p.value)
      )
    )

  dplyr::bind_rows(
    kruskal_tidy,
    pairwise_rows,
    chisq_row,
    safe_obgyn_trend_row(time_trends_tbl, year_col)
  )
}
