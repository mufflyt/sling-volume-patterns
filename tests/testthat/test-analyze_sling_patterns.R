# =============================================================================
# test-analyze_sling_patterns.R
#
# testthat unit tests for analyze_midurethral_sling_patterns() and all
# internal helper functions.
#
# Test philosophy:
#   - TDD: tests define the contract before code is accepted
#   - Each unit test < 1 second
#   - Hall of Shame fixtures for every known edge-case bug
#   - Property invariants verified after every operation
#   - Fail fast: assert_that() guards catch misuse immediately
#
# API note (2026 refactor): the pipeline was migrated from the original
# "FPMRS + low-volume threshold" design to the current
# "URPS + Gini/concentration" design (see README "Design Decisions").
# These tests target the current API:
#   - classify_provider_specialty() returns "URPS" (formerly "FPMRS")
#   - analyze_midurethral_sling_patterns() returns
#       provider_volume / specialty_summary / concentration_metrics /
#       time_trends  (there is no low_volume_burden element, no
#       low_volume_threshold argument, and no volume_tier column)
#   - concentration is measured with Gini coefficients and top-N% shares
# =============================================================================

library(testthat)
library(tibble)
library(dplyr)

# ── Shared fixtures ──────────────────────────────────────────────────────────

#' Minimal valid Medicare PUF with CPT 57288 rows
make_minimal_puf <- function() {
  tibble::tibble(
    Rndrng_NPI        = as.character(c(1001, 1002, 1003, 1004, 1005)),
    Rndrng_Prvdr_Type = c(
      "Urogynecology",
      "Obstetrics & Gynecology",
      "Urology",
      "Internal Medicine",
      "Urogynecology"
    ),
    HCPCS_Cd  = "57288",
    Tot_Srvcs = c(45L, 6L, 14L, 3L, 38L)
  )
}

#' PUF that includes non-57288 rows — these must be dropped silently
make_puf_with_mixed_cpts <- function() {
  tibble::tibble(
    Rndrng_NPI        = as.character(1001:1006),
    Rndrng_Prvdr_Type = c(
      "Urogynecology",
      "Urogynecology",
      "Obstetrics & Gynecology",
      "Urology",
      "Urology",
      "Family Medicine"
    ),
    HCPCS_Cd  = c("57288", "99213", "57288", "57288", "90837", "57288"),
    Tot_Srvcs = c(40L, 200L, 5L, 12L, 100L, 8L)
  )
}

#' Multi-year PUF for trend analysis
make_puf_multiyear <- function() {
  tibble::tibble(
    Rndrng_NPI        = rep(as.character(1001:1006), times = 3),
    Rndrng_Prvdr_Type = rep(c(
      "Urogynecology",
      "Urogynecology",
      "Obstetrics & Gynecology",
      "Obstetrics & Gynecology",
      "Urology",
      "Internal Medicine"
    ), times = 3),
    HCPCS_Cd  = "57288",
    Tot_Srvcs = c(
      40L, 35L, 5L, 7L, 12L, 3L,   # 2020
      45L, 38L, 6L, 9L, 15L, 4L,   # 2021
      50L, 42L, 8L, 11L, 18L, 2L   # 2022
    ),
    year = rep(2020L:2022L, each = 6L)
  )
}

# ── Hall of Shame fixtures (regression tests for known bugs) ─────────────────

# BUG: duplicate NPI rows in the same year inflate sling counts
# Fixed by group_by + summarise in aggregate_to_provider_level()
make_duplicate_npi_hall_of_shame <- function() {
  tibble::tibble(
    Rndrng_NPI        = c("1001", "1001", "1002"),
    Rndrng_Prvdr_Type = c("Urogynecology", "Urogynecology",
                          "Obstetrics & Gynecology"),
    HCPCS_Cd          = "57288",
    Tot_Srvcs         = c(20L, 25L, 5L)  # 1001 split across two rows
  )
}

# BUG: NA in Tot_Srvcs causes silent sum() = NA without na.rm = TRUE
make_na_services_hall_of_shame <- function() {
  tibble::tibble(
    Rndrng_NPI        = as.character(1001:1004),
    Rndrng_Prvdr_Type = c("Urogynecology", "Urology",
                          "Obstetrics & Gynecology", "Urology"),
    HCPCS_Cd          = "57288",
    Tot_Srvcs         = c(30L, NA_integer_, 8L, 12L)
  )
}

# BUG: same NPI appears with two different provider type strings (data
# quality issue common in real Medicare PUF). Grouping by NPI+provider_type
# creates two rows per NPI, breaking all downstream uniqueness invariants.
make_conflicting_provider_type_hall_of_shame <- function() {
  tibble::tibble(
    Rndrng_NPI        = c("1001", "1001", "1002"),
    Rndrng_Prvdr_Type = c(
      "Urogynecology",
      "Obstetrics & Gynecology",  # same NPI, different provider type string
      "Urology"
    ),
    HCPCS_Cd  = "57288",
    Tot_Srvcs = c(20L, 25L, 12L)
  )
}

# BUG: provider type string with mixed casing breaks regex classification.
# Tests that ignore_case = TRUE applies to all four specialty patterns.
# CRITICAL: This function was accidentally deleted in a prior edit, leaving
# its body as orphaned code with an unmatched `}` that caused a parse error
# crashing every single test in this file.
make_mixed_case_provider_type_hall_of_shame <- function() {
  tibble::tibble(
    Rndrng_NPI        = as.character(1001:1004),
    Rndrng_Prvdr_Type = c(
      "UROGYNECOLOGY",           # all caps
      "obstetrics & gynecology", # all lower
      "UROLOGY",
      "Female Pelvic Medicine & Reconstructive Surgery"
    ),
    HCPCS_Cd  = "57288",
    Tot_Srvcs = c(30L, 6L, 14L, 45L)
  )
}


# =============================================================================
# Tests: classify_provider_specialty()
# =============================================================================

test_that("classify_provider_specialty: URPS patterns resolve correctly", {
  urps_types <- c(
    "Urogynecology",
    "Female Pelvic Medicine & Reconstructive Surgery",
    "Pelvic Floor Specialist",
    "Female Pelvic Medicine"
  )
  result_groups <- classify_provider_specialty(urps_types)
  expect_true(all(result_groups == "URPS"))
})

test_that("classify_provider_specialty: OB/GYN patterns resolve correctly", {
  obgyn_types <- c(
    "Obstetrics & Gynecology",
    "Obstetrics",
    "Gynecology",
    "Gynecologic Oncology",
    "ob/gyn",
    "OB-GYN"
  )
  result_groups <- classify_provider_specialty(obgyn_types)
  expect_true(all(result_groups == "OB/GYN"))
})

test_that("classify_provider_specialty: Urology patterns resolve correctly", {
  urology_types <- c("Urology", "Urological Surgery", "Urogynecology")
  result_groups <- classify_provider_specialty(urology_types)
  # First two are Urology; Urogynecology must be URPS (hierarchy)
  expect_equal(result_groups[1], "Urology")
  expect_equal(result_groups[2], "Urology")
  expect_equal(result_groups[3], "URPS")
})

test_that("classify_provider_specialty: URPS wins over OB/GYN in hierarchy", {
  # "Urogynecology" contains 'gynecolog' — but the URPS check comes first
  expect_equal(
    classify_provider_specialty("Urogynecology"),
    "URPS"
  )
})

test_that("classify_provider_specialty: Other catches unknown types", {
  other_types <- c(
    "Internal Medicine",
    "Family Medicine",
    "Physical Medicine & Rehabilitation",
    "Nurse Practitioner"
  )
  result_groups <- classify_provider_specialty(other_types)
  expect_true(all(result_groups == "Other"))
})

test_that(
  "classify_provider_specialty: Hall of Shame — mixed case is handled",
  {
    puf <- make_mixed_case_provider_type_hall_of_shame()
    result_groups <- classify_provider_specialty(puf$Rndrng_Prvdr_Type)
    # UROGYNECOLOGY → URPS (ignore_case = TRUE)
    expect_equal(result_groups[1], "URPS")
    # obstetrics & gynecology → OB/GYN
    expect_equal(result_groups[2], "OB/GYN")
    # UROLOGY → Urology
    expect_equal(result_groups[3], "Urology")
    # Female Pelvic Medicine → URPS
    expect_equal(result_groups[4], "URPS")
  }
)

test_that("classify_provider_specialty: rejects non-character input", {
  expect_error(
    classify_provider_specialty(c(1, 2, 3)),
    regexp = "character"
  )
})

test_that("classify_provider_specialty: handles empty character vector", {
  result_groups <- classify_provider_specialty(character(0))
  expect_length(result_groups, 0)
})

test_that("classify_provider_specialty: NA input is classified as 'Other'", {
  # In dplyr::case_when(), str_detect(NA, regex) returns NA which is treated
  # as FALSE. The TRUE ~ "Other" catch-all therefore fires, returning "Other".
  result_groups <- classify_provider_specialty(c("Urology", NA_character_))
  expect_equal(result_groups[1], "Urology")
  expect_equal(result_groups[2], "Other")
})


# =============================================================================
# Tests: validate_sling_input()
# =============================================================================

test_that("validate_sling_input: accepts valid minimal PUF", {
  expect_true(validate_sling_input(make_minimal_puf()))
})

test_that("validate_sling_input: rejects non-data-frame input", {
  expect_error(
    validate_sling_input(list(a = 1, b = 2)),
    regexp = "data frame"
  )
})

test_that("validate_sling_input: rejects missing required columns", {
  bad_puf <- dplyr::select(make_minimal_puf(), -Tot_Srvcs)
  expect_error(
    validate_sling_input(bad_puf),
    regexp = "Tot_Srvcs"
  )
})

test_that("validate_sling_input: rejects empty data frame", {
  empty_puf <- make_minimal_puf()[0, ]
  expect_error(
    validate_sling_input(empty_puf),
    regexp = "at least one row"
  )
})

test_that("validate_sling_input: rejects bad year_col name", {
  expect_error(
    validate_sling_input(make_minimal_puf(), year_col = "nonexistent_column"),
    regexp = "nonexistent_column"
  )
})

test_that("validate_sling_input: rejects non-character year_col", {
  expect_error(
    validate_sling_input(make_minimal_puf(), year_col = 2020),
    regexp = "character"
  )
})


# =============================================================================
# Tests: filter_to_sling_cpt()
# =============================================================================

test_that("filter_to_sling_cpt: retains only HCPCS_Cd == '57288'", {
  mixed_puf <- make_puf_with_mixed_cpts()
  sling_only <- filter_to_sling_cpt(mixed_puf, verbose = FALSE)
  expect_true(all(sling_only$HCPCS_Cd == "57288"))
})

test_that("filter_to_sling_cpt: drops non-57288 rows silently", {
  mixed_puf <- make_puf_with_mixed_cpts()
  # 4 of 6 rows are 57288
  sling_only <- filter_to_sling_cpt(mixed_puf, verbose = FALSE)
  expect_equal(nrow(sling_only), 4L)
})

test_that("filter_to_sling_cpt: errors when no 57288 rows exist", {
  no_sling_puf <- dplyr::mutate(make_minimal_puf(), HCPCS_Cd = "99213")
  expect_error(
    filter_to_sling_cpt(no_sling_puf, verbose = FALSE),
    regexp = "57288"
  )
})


# =============================================================================
# Tests: compute_gini() / compute_top_pct_share()
# =============================================================================

test_that("compute_gini: perfect equality is 0, extreme inequality approaches 1", {
  # All equal → Gini 0
  expect_equal(compute_gini(rep(10, 100)), 0)
  # One provider holds essentially everything → Gini near 1
  extreme <- c(rep(0.0001, 999), 1e6)
  expect_gt(compute_gini(extreme), 0.9)
})

test_that("compute_gini: returns NA for degenerate input", {
  expect_true(is.na(compute_gini(numeric(0))))
  expect_true(is.na(compute_gini(5)))       # n < 2
  expect_true(is.na(compute_gini(c(0, 0)))) # sum == 0
})

test_that("compute_top_pct_share: top 20% share is a percentage in [0, 100]", {
  vols <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
  share <- compute_top_pct_share(vols, top_pct = 0.20)
  expect_true(share > 0 && share <= 100)
  # Top 20% (2 of 10 providers: 9 + 10 = 19 of 55 total) ≈ 34.5%
  expect_equal(round(share, 1), 34.5)
})


# =============================================================================
# Tests: build_specialty_summary()
# =============================================================================

test_that("build_specialty_summary: pct_of_all_slings sums to 100", {
  puf           <- make_minimal_puf()
  sling_data    <- dplyr::mutate(
    puf,
    specialty_group = classify_provider_specialty(Rndrng_Prvdr_Type)
  )
  provider_vol  <- dplyr::group_by(
    sling_data, Rndrng_NPI, Rndrng_Prvdr_Type, specialty_group
  ) |>
    dplyr::summarise(
      annual_sling_count = sum(Tot_Srvcs, na.rm = TRUE),
      .groups = "drop"
    )
  specialty_summary <- build_specialty_summary(provider_vol, verbose = FALSE)
  expect_equal(
    round(sum(specialty_summary$pct_of_all_slings), 1),
    100
  )
})

test_that("build_specialty_summary: sorted descending by total_slings", {
  puf           <- make_minimal_puf()
  sling_data    <- dplyr::mutate(
    puf,
    specialty_group = classify_provider_specialty(Rndrng_Prvdr_Type)
  )
  provider_vol  <- dplyr::group_by(
    sling_data, Rndrng_NPI, Rndrng_Prvdr_Type, specialty_group
  ) |>
    dplyr::summarise(
      annual_sling_count = sum(Tot_Srvcs, na.rm = TRUE),
      .groups = "drop"
    )
  specialty_summary <- build_specialty_summary(provider_vol, verbose = FALSE)
  expect_equal(
    specialty_summary$total_slings,
    sort(specialty_summary$total_slings, decreasing = TRUE)
  )
})

test_that("build_specialty_summary: emits a Gini coefficient per group in [0, 1)", {
  provider_vol <- tibble::tibble(
    Rndrng_NPI = c("1001", "1002", "1003", "1004"),
    specialty_group = c("URPS", "URPS", "OB/GYN", "OB/GYN"),
    annual_sling_count = c(8L, 15L, 5L, 6L)
  )
  specialty_summary <- build_specialty_summary(provider_vol, verbose = FALSE)
  expect_true("gini_coefficient" %in% names(specialty_summary))
  expect_true(all(
    specialty_summary$gini_coefficient >= 0 &
      specialty_summary$gini_coefficient < 1
  ))
})


# =============================================================================
# Tests: build_concentration_metrics()
# =============================================================================

test_that("build_concentration_metrics: emits Gini and one top-N% column per cutoff", {
  provider_vol <- tibble::tibble(
    Rndrng_NPI = as.character(1001:1010),
    specialty_group = rep(c("URPS", "Urology"), each = 5),
    annual_sling_count = c(10L, 12L, 14L, 40L, 60L, 11L, 13L, 15L, 20L, 90L)
  )
  metrics <- build_concentration_metrics(
    provider_vol,
    concentration_cutoffs = c(10, 20, 30),
    verbose = FALSE
  )
  expect_true(all(
    c("specialty_group", "gini_coefficient", "n_providers",
      "pct_by_top_10", "pct_by_top_20", "pct_by_top_30") %in% names(metrics)
  ))
  # One row per specialty group
  expect_equal(nrow(metrics), 2L)
  # Top-share columns are ordered: top 10% <= top 20% <= top 30%
  expect_true(all(metrics$pct_by_top_10 <= metrics$pct_by_top_20))
  expect_true(all(metrics$pct_by_top_20 <= metrics$pct_by_top_30))
})


# =============================================================================
# Tests: analyze_midurethral_sling_patterns() — integration
# =============================================================================

test_that("main function: returns a list with four named elements", {
  result_list <- analyze_midurethral_sling_patterns(
    medicare_puf_data = make_minimal_puf(),
    year_col          = NULL,
    verbose           = FALSE
  )
  expect_type(result_list, "list")
  expect_named(
    result_list,
    c("provider_volume", "specialty_summary", "concentration_metrics",
      "time_trends")
  )
})

test_that("main function: time_trends is NULL when year_col = NULL", {
  result_list <- analyze_midurethral_sling_patterns(
    medicare_puf_data = make_minimal_puf(),
    year_col          = NULL,
    verbose           = FALSE
  )
  expect_null(result_list$time_trends)
})

test_that("main function: time_trends is a tibble when year_col is set", {
  result_list <- analyze_midurethral_sling_patterns(
    medicare_puf_data = make_puf_multiyear(),
    year_col          = "year",
    verbose           = FALSE
  )
  expect_true(is.data.frame(result_list$time_trends))
  expect_true(nrow(result_list$time_trends) > 0L)
})

test_that("main function: provider_volume has required columns", {
  result_list <- analyze_midurethral_sling_patterns(
    medicare_puf_data = make_minimal_puf(),
    verbose           = FALSE
  )
  required_columns <- c(
    "Rndrng_NPI", "Rndrng_Prvdr_Type",
    "specialty_group", "annual_sling_count", "subspecialty_abog"
  )
  expect_true(
    all(required_columns %in% names(result_list$provider_volume))
  )
})

test_that("main function: specialty_summary has required columns", {
  result_list <- analyze_midurethral_sling_patterns(
    medicare_puf_data = make_minimal_puf(),
    verbose           = FALSE
  )
  required_columns <- c(
    "specialty_group", "n_providers", "total_slings",
    "median_annual_volume", "mean_annual_volume",
    "gini_coefficient", "pct_of_all_slings"
  )
  expect_true(
    all(required_columns %in% names(result_list$specialty_summary))
  )
})

test_that("main function: concentration_metrics has required columns", {
  result_list <- analyze_midurethral_sling_patterns(
    medicare_puf_data = make_minimal_puf(),
    verbose           = FALSE
  )
  required_columns <- c(
    "specialty_group", "gini_coefficient", "pct_by_top_20"
  )
  expect_true(
    all(required_columns %in% names(result_list$concentration_metrics))
  )
})

test_that("main function: non-57288 rows are dropped before analysis", {
  mixed_puf   <- make_puf_with_mixed_cpts()
  result_list <- analyze_midurethral_sling_patterns(
    medicare_puf_data = mixed_puf,
    verbose           = FALSE
  )
  # NPI 1002 (only row is 99213) must not appear in provider_volume
  expect_false("1002" %in% result_list$provider_volume$Rndrng_NPI)
  # NPI 1005 (only row is 90837) must not appear either
  expect_false("1005" %in% result_list$provider_volume$Rndrng_NPI)
})

test_that("main function: rejects missing required column", {
  bad_puf <- dplyr::select(make_minimal_puf(), -HCPCS_Cd)
  expect_error(
    analyze_midurethral_sling_patterns(bad_puf, verbose = FALSE),
    regexp = "HCPCS_Cd"
  )
})

test_that("main function: rejects non-logical verbose argument", {
  expect_error(
    analyze_midurethral_sling_patterns(
      make_minimal_puf(),
      verbose = "yes"
    ),
    regexp = "TRUE or FALSE"
  )
})

test_that("main function: runs silently when verbose = FALSE", {
  expect_silent(
    analyze_midurethral_sling_patterns(
      medicare_puf_data = make_minimal_puf(),
      verbose           = FALSE
    )
  )
})

test_that("main function: pct_of_all_slings sums to 100 across groups", {
  result_list <- analyze_midurethral_sling_patterns(
    medicare_puf_data = make_minimal_puf(),
    verbose           = FALSE
  )
  expect_equal(
    round(sum(result_list$specialty_summary$pct_of_all_slings), 1),
    100
  )
})

test_that("main function: time_trends has correct year column", {
  result_list <- analyze_midurethral_sling_patterns(
    medicare_puf_data = make_puf_multiyear(),
    year_col          = "year",
    verbose           = FALSE
  )
  expect_true("year" %in% names(result_list$time_trends))
  expect_equal(
    sort(unique(result_list$time_trends$year)),
    2020L:2022L
  )
})

test_that("main function: time_trends includes pct_slings_this_year", {
  result_list <- analyze_midurethral_sling_patterns(
    medicare_puf_data = make_puf_multiyear(),
    year_col          = "year",
    verbose           = FALSE
  )
  expect_true("pct_slings_this_year" %in% names(result_list$time_trends))
  # Within each year, specialty shares must sum to 100
  yearly_sums <- result_list$time_trends |>
    dplyr::group_by(year) |>
    dplyr::summarise(
      year_total_pct = sum(pct_slings_this_year, na.rm = TRUE),
      .groups = "drop"
    )
  expect_true(all(abs(yearly_sums$year_total_pct - 100) < 0.01))
})

# ── Hall of Shame regression tests ──────────────────────────────────────────

test_that(
  "Hall of Shame — duplicate NPI rows: sling count is summed, not doubled",
  {
    # NPI 1001 appears in two rows: Tot_Srvcs = 20 and 25 → should be 45
    puf <- make_duplicate_npi_hall_of_shame()
    result_list <- analyze_midurethral_sling_patterns(
      puf, verbose = FALSE
    )
    npi_1001_count <- result_list$provider_volume |>
      dplyr::filter(Rndrng_NPI == "1001") |>
      dplyr::pull(annual_sling_count)
    expect_equal(npi_1001_count, 45L)
    # Exactly one row per NPI
    npi_1001_row_count <- result_list$provider_volume |>
      dplyr::filter(Rndrng_NPI == "1001") |>
      nrow()
    expect_equal(npi_1001_row_count, 1L)
  }
)

test_that(
  "Hall of Shame — NA in Tot_Srvcs: na.rm = TRUE prevents NA propagation",
  {
    puf <- make_na_services_hall_of_shame()
    result_list <- analyze_midurethral_sling_patterns(
      puf, verbose = FALSE
    )
    # Total slings must be numeric and non-NA
    expect_false(any(is.na(result_list$specialty_summary$total_slings)))
    expect_false(any(is.na(result_list$provider_volume$annual_sling_count)))
  }
)

test_that(
  "Hall of Shame — mixed-case provider type: regex is case-insensitive",
  {
    puf <- make_mixed_case_provider_type_hall_of_shame()
    result_list <- analyze_midurethral_sling_patterns(
      puf, verbose = FALSE
    )
    specialty_groups <- result_list$provider_volume$specialty_group
    # No provider should fall to "Other" — all four types are recognizable
    expect_false("Other" %in% specialty_groups)
    # Both URPS providers correctly identified
    n_urps <- sum(specialty_groups == "URPS")
    expect_equal(n_urps, 2L)
  }
)

test_that(
  "Hall of Shame — conflicting provider types for same NPI: detected and errored",
  {
    # Real Medicare PUF data quality issue: same NPI billed with two
    # different Rndrng_Prvdr_Type strings. Must fail loudly, not silently
    # produce two rows for NPI 1001 downstream.
    puf <- make_conflicting_provider_type_hall_of_shame()
    expect_error(
      analyze_midurethral_sling_patterns(puf, verbose = FALSE),
      regexp = "more than one"
    )
  }
)

# =============================================================================
# Tests: reporting_stats_helpers.R
# =============================================================================

test_that("safe_pairwise_wilcox_tidy returns an NA row when a focal group is absent", {
  provider_vol <- tibble::tibble(
    Rndrng_NPI = c("1001", "1002"),
    specialty_group = c("OB/GYN", "OB/GYN"),
    annual_sling_count = c(12L, 18L)
  )

  pairwise_tidy <- safe_pairwise_wilcox_tidy(provider_vol)

  expect_equal(nrow(pairwise_tidy), 1L)
  expect_true(is.na(pairwise_tidy$p.value))
  expect_match(pairwise_tidy$test, "not computed")
})

test_that("validate_reporting_analysis_output enforces required specialties and columns", {
  result_list <- analyze_midurethral_sling_patterns(
    make_minimal_puf(),
    verbose = FALSE
  )

  expect_true(
    validate_reporting_analysis_output(
      result_list,
      required_specialty_groups = c("OB/GYN", "Urology")
    )
  )

  bad_result <- result_list
  bad_result$provider_volume <- dplyr::select(
    bad_result$provider_volume,
    -annual_sling_count
  )
  expect_error(
    validate_reporting_analysis_output(bad_result),
    regexp = "annual_sling_count"
  )
})

test_that("build_focal_stats_table returns publication-ready rows", {
  result_list <- analyze_midurethral_sling_patterns(
    make_puf_multiyear(),
    year_col = "year",
    verbose = FALSE
  )

  stats_table <- build_focal_stats_table(
    result_list$provider_volume,
    time_trends_tbl = result_list$time_trends,
    year_col = "year"
  )

  expect_true(
    all(c("test", "statistic", "df", "p_value", "p_formatted") %in% names(stats_table))
  )
  expect_true(any(stats_table$test == "Kruskal-Wallis: annual volume across specialty groups"))
  expect_true(any(stats_table$test == "Linear regression: gynecologic market share ~ year"))
})

test_that("build_focal_stats_table handles a missing focal specialty without error", {
  # Two groups are present (so Kruskal-Wallis is computable), but the focal
  # comparison OB/GYN vs Urology is missing Urology → Wilcoxon not computed.
  provider_vol <- tibble::tibble(
    Rndrng_NPI = c("1001", "1002", "1003"),
    specialty_group = c("OB/GYN", "OB/GYN", "URPS"),
    annual_sling_count = c(12L, 18L, 20L)
  )

  stats_table <- build_focal_stats_table(provider_vol)

  wilcox_row <- dplyr::filter(
    stats_table,
    test == "Wilcoxon (Bonferroni): OB/GYN vs Urology"
  )
  expect_equal(nrow(wilcox_row), 1L)
  expect_equal(wilcox_row$p_formatted, "NA (not computed)")
})

# =============================================================================
# Tests: generate_sling_abstract()
# =============================================================================

test_that("generate_sling_abstract handles a non-computable trend test", {
  # Only two calendar years → the linear market-share trend needs ≥ 3 years
  # and must degrade to NA rather than erroring.
  puf <- tibble::tibble(
    Rndrng_NPI        = c("1001", "1001", "1002", "1002"),
    Rndrng_Prvdr_Type = c(
      "Obstetrics & Gynecology", "Obstetrics & Gynecology",
      "Urology", "Urology"
    ),
    HCPCS_Cd  = "57288",
    Tot_Srvcs = c(12L, 14L, 15L, 18L),
    year      = c(2021L, 2022L, 2021L, 2022L)
  )
  result_list <- analyze_midurethral_sling_patterns(
    puf,
    year_col = "year",
    verbose = FALSE
  )

  abstract_result <- generate_sling_abstract(
    sling_analysis_output = result_list,
    year_col = "year",
    study_years = c(2021L, 2022L),
    verbose = FALSE
  )

  trend_row <- dplyr::filter(
    abstract_result$stats_table,
    test == "Linear regression: gynecologic market share ~ year"
  )

  expect_equal(trend_row$p_formatted, "NA (not computed)")
  expect_true(is.na(abstract_result$filled_values$obgyn_trend_p))
})

test_that("generate_sling_abstract filled_values agree with specialty_summary", {
  result_list <- analyze_midurethral_sling_patterns(
    make_puf_multiyear(),
    year_col = "year",
    verbose = FALSE
  )
  abstract_result <- generate_sling_abstract(
    sling_analysis_output = result_list,
    year_col = "year",
    study_years = c(2020L, 2022L),
    verbose = FALSE
  )

  # Every focal specialty's audited share must match the summary table exactly.
  focal_groups <- result_list$specialty_summary |>
    dplyr::filter(specialty_group != "Other") |>
    dplyr::pull(specialty_group)

  for (sg in focal_groups) {
    sg_key <- tolower(gsub("[/ ]", "_", sg))
    audited <- abstract_result$filled_values[[paste0(sg_key, "_pct_of_all_slings")]]
    expected <- result_list$specialty_summary |>
      dplyr::filter(specialty_group == sg) |>
      dplyr::pull(pct_of_all_slings)
    expect_equal(audited, expected)
  }
})

test_that("manifest_verify errors on missing artifacts", {
  cache_dir <- tempfile("artifact-cache-")
  dir.create(cache_dir, recursive = TRUE)
  missing_path <- file.path(cache_dir, "missing.rds")

  write_manifest(
    list(example = list(
      file_path = missing_path,
      sha256 = "abc123",
      phase = "test",
      phase_script = "test",
      timestamp = "2026-04-01T00:00:00",
      size_bytes = 0
    )),
    cache_dir = cache_dir
  )

  # manifest_verify() emits a per-artifact "MISSING:" warning before it
  # aborts with the summary error; suppress the intentional warning so the
  # test asserts only the error contract.
  expect_error(
    suppressWarnings(manifest_verify(cache_dir, verbose = FALSE)),
    regexp = "missing artifact"
  )
})

# ── Property invariant tests ─────────────────────────────────────────────────

test_that("Invariant: each NPI appears at most once in provider_volume (cross-sectional)", {
  result_list <- analyze_midurethral_sling_patterns(
    make_minimal_puf(), verbose = FALSE
  )
  npi_counts <- dplyr::count(result_list$provider_volume, Rndrng_NPI)
  expect_true(all(npi_counts$n == 1L))
})

test_that("Invariant: each NPI appears at most once per year in provider_volume (multi-year)", {
  result_list <- analyze_midurethral_sling_patterns(
    make_puf_multiyear(), year_col = "year", verbose = FALSE
  )
  npi_year_counts <- dplyr::count(
    result_list$provider_volume, Rndrng_NPI, year
  )
  expect_true(all(npi_year_counts$n == 1L))
})

test_that("Invariant: all specialty_group values are in allowed set", {
  result_list <- analyze_midurethral_sling_patterns(
    make_minimal_puf(), verbose = FALSE
  )
  # "Other" is excluded inside the main function; without an ABOG crosswalk
  # OB/GYN is not split into MIGS / General OB/GYN, but those remain valid
  # labels the pipeline can emit.
  allowed_specialty_groups <- c(
    "URPS", "OB/GYN", "Urology", "MIGS", "General OB/GYN"
  )
  observed_groups <- unique(result_list$provider_volume$specialty_group)
  expect_true(all(observed_groups %in% allowed_specialty_groups))
})

test_that("Invariant: annual_sling_count is always positive", {
  result_list <- analyze_midurethral_sling_patterns(
    make_minimal_puf(), verbose = FALSE
  )
  expect_true(all(result_list$provider_volume$annual_sling_count > 0))
})

test_that("Invariant: n_providers in specialty_summary <= nrow(provider_volume)", {
  result_list <- analyze_midurethral_sling_patterns(
    make_minimal_puf(), verbose = FALSE
  )
  expect_true(
    sum(result_list$specialty_summary$n_providers) <=
      nrow(result_list$provider_volume)
  )
})

test_that(
  paste0(
    "Invariant: concentration_metrics n_providers matches specialty_summary ",
    "n_providers per group"
  ),
  {
    # Both tables aggregate to unique NPIs; per specialty they must agree.
    result_list <- analyze_midurethral_sling_patterns(
      make_puf_multiyear(), year_col = "year", verbose = FALSE
    )
    comparison <- dplyr::left_join(
      dplyr::select(result_list$concentration_metrics,
                    specialty_group, conc_n = n_providers),
      dplyr::select(result_list$specialty_summary,
                    specialty_group, summary_n = n_providers),
      by = "specialty_group"
    )
    expect_true(all(comparison$conc_n == comparison$summary_n))
  }
)
