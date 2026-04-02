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

# BUG: n_low_volume_providers used sum(count < threshold) over NPI-year
# rows, double-counting providers who appear in multiple years.
# Fixture: NPI 1001 is low-volume in 2020 (count=8) but high in 2021 (15).
make_multi_year_low_volume_hall_of_shame <- function() {
  tibble::tibble(
    Rndrng_NPI        = c("1001", "1001", "1002", "1002"),
    Rndrng_Prvdr_Type = c(
      "Urogynecology", "Urogynecology",
      "Obstetrics & Gynecology", "Obstetrics & Gynecology"
    ),
    HCPCS_Cd  = "57288",
    Tot_Srvcs = c(8L, 15L, 5L, 6L),   # 1001: low 2020, high 2021
    year      = c(2020L, 2021L, 2020L, 2021L)
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

test_that("classify_provider_specialty: FPMRS patterns resolve correctly", {
  fpmrs_types <- c(
    "Urogynecology",
    "Female Pelvic Medicine & Reconstructive Surgery",
    "Pelvic Floor Specialist",
    "Female Pelvic Medicine"
  )
  result_groups <- classify_provider_specialty(fpmrs_types)
  expect_true(all(result_groups == "FPMRS"))
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
  # First two are Urology; Urogynecology must be FPMRS (hierarchy)
  expect_equal(result_groups[1], "Urology")
  expect_equal(result_groups[2], "Urology")
  expect_equal(result_groups[3], "FPMRS")
})

test_that("classify_provider_specialty: FPMRS wins over OB/GYN in hierarchy", {
  # "Urogynecology" contains 'gynecolog' — but FPMRS check comes first
  expect_equal(
    classify_provider_specialty("Urogynecology"),
    "FPMRS"
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
    # UROGYNECOLOGY → FPMRS (ignore_case = TRUE)
    expect_equal(result_groups[1], "FPMRS")
    # obstetrics & gynecology → OB/GYN
    expect_equal(result_groups[2], "OB/GYN")
    # UROLOGY → Urology
    expect_equal(result_groups[3], "Urology")
    # Female Pelvic Medicine → FPMRS
    expect_equal(result_groups[4], "FPMRS")
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
  # Bug fix for test: the previous test expected is.na(result) for NA input.
  # In dplyr::case_when(), str_detect(NA, regex) returns NA which is treated
  # as FALSE. The TRUE ~ "Other" catch-all therefore fires, returning "Other".
  # The old comment "NA input → NA output (case_when propagates NA)" was wrong.
  result_groups <- classify_provider_specialty(c("Urology", NA_character_))
  expect_equal(result_groups[1], "Urology")
  expect_equal(result_groups[2], "Other")
})


# =============================================================================
# Tests: assign_volume_tier()
# =============================================================================

test_that("assign_volume_tier: low < threshold", {
  tier <- assign_volume_tier(c(1L, 5L, 9L), low_volume_threshold = 10L)
  expect_true(all(stringr::str_detect(tier, "Low")))
})

test_that("assign_volume_tier: high >= threshold * 2.5", {
  tier <- assign_volume_tier(c(25L, 50L, 100L), low_volume_threshold = 10L)
  expect_true(all(stringr::str_detect(tier, "High")))
})

test_that("assign_volume_tier: medium between low and high", {
  tier <- assign_volume_tier(c(10L, 15L, 24L), low_volume_threshold = 10L)
  expect_true(all(stringr::str_detect(tier, "Medium")))
})

test_that("assign_volume_tier: threshold = 5 changes tier boundaries", {
  tiers <- assign_volume_tier(c(4L, 7L, 13L), low_volume_threshold = 5L)
  expect_true(stringr::str_detect(tiers[1], "Low"))
  expect_true(stringr::str_detect(tiers[2], "Medium"))
  expect_true(stringr::str_detect(tiers[3], "High"))
})

test_that("assign_volume_tier: rejects non-numeric count vector", {
  expect_error(
    assign_volume_tier(c("10", "20"), low_volume_threshold = 10L),
    regexp = "numeric"
  )
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
  specialty_summary <- build_specialty_summary(
    provider_vol, low_volume_threshold = 10L, verbose = FALSE
  )
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
  specialty_summary <- build_specialty_summary(
    provider_vol, low_volume_threshold = 10L, verbose = FALSE
  )
  expect_equal(
    specialty_summary$total_slings,
    sort(specialty_summary$total_slings, decreasing = TRUE)
  )
})

test_that("build_specialty_summary: low-volume uses mean annual volume per provider", {
  provider_vol <- tibble::tibble(
    Rndrng_NPI = c("1001", "1001", "1002", "1002"),
    specialty_group = c("FPMRS", "FPMRS", "OB/GYN", "OB/GYN"),
    annual_sling_count = c(8L, 15L, 5L, 6L)
  )
  specialty_summary <- build_specialty_summary(
    provider_vol,
    low_volume_threshold = 10L,
    verbose = FALSE
  )
  fpmrs_row <- dplyr::filter(specialty_summary, specialty_group == "FPMRS")
  obgyn_row <- dplyr::filter(specialty_summary, specialty_group == "OB/GYN")

  expect_equal(fpmrs_row$n_low_volume_providers, 0L)
  expect_equal(fpmrs_row$pct_low_volume_providers, 0)
  expect_equal(obgyn_row$n_low_volume_providers, 1L)
  expect_equal(obgyn_row$pct_low_volume_providers, 100)
})


# =============================================================================
# Tests: analyze_midurethral_sling_patterns() — integration
# =============================================================================

test_that("main function: returns a list with four named elements", {
  result_list <- analyze_midurethral_sling_patterns(
    medicare_puf_data    = make_minimal_puf(),
    year_col             = NULL,
    low_volume_threshold = 10L,
    verbose              = FALSE
  )
  expect_type(result_list, "list")
  expect_named(
    result_list,
    c("provider_volume", "specialty_summary", "low_volume_burden",
      "time_trends")
  )
})

test_that("main function: time_trends is NULL when year_col = NULL", {
  result_list <- analyze_midurethral_sling_patterns(
    medicare_puf_data    = make_minimal_puf(),
    year_col             = NULL,
    low_volume_threshold = 10L,
    verbose              = FALSE
  )
  expect_null(result_list$time_trends)
})

test_that("main function: time_trends is a tibble when year_col is set", {
  result_list <- analyze_midurethral_sling_patterns(
    medicare_puf_data    = make_puf_multiyear(),
    year_col             = "year",
    low_volume_threshold = 10L,
    verbose              = FALSE
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
    "specialty_group", "annual_sling_count", "volume_tier"
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
    "median_annual_volume", "pct_of_all_slings"
  )
  expect_true(
    all(required_columns %in% names(result_list$specialty_summary))
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

test_that("main function: rejects non-positive low_volume_threshold", {
  expect_error(
    analyze_midurethral_sling_patterns(
      make_minimal_puf(),
      low_volume_threshold = 0L,
      verbose              = FALSE
    ),
    regexp = "positive"
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

test_that("main function: custom threshold changes volume tier labels", {
  result_default <- analyze_midurethral_sling_patterns(
    make_minimal_puf(), low_volume_threshold = 10L, verbose = FALSE
  )
  result_strict <- analyze_midurethral_sling_patterns(
    make_minimal_puf(), low_volume_threshold = 5L, verbose = FALSE
  )
  # Tier labels embed the threshold value — they must differ
  expect_false(
    identical(
      result_default$provider_volume$volume_tier,
      result_strict$provider_volume$volume_tier
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
    # Both FPMRS providers correctly identified
    n_fpmrs <- sum(specialty_groups == "FPMRS")
    expect_equal(n_fpmrs, 2L)
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

test_that(
  paste0(
    "Hall of Shame — multi-year n_low_volume_providers: ",
    "uses mean annual volume per NPI"
  ),
  {
    # NPI 1001: low-volume in 2020 (8), high-volume in 2021 (15).
    # Mean annual volume is 11.5, so this provider must NOT be low-volume.
    # NPI 1002: low-volume in both years (5, 6) — counts as 1 unique provider.
    # FPMRS n_low_volume_providers must be 0,
    # OB/GYN n_low_volume_providers must be 1 (NPI 1002 always low-volume).
    puf <- make_multi_year_low_volume_hall_of_shame()
    result_list <- analyze_midurethral_sling_patterns(
      puf, year_col = "year", verbose = FALSE
    )
    fpmrs_row <- dplyr::filter(
      result_list$specialty_summary,
      specialty_group == "FPMRS"
    )
    obgyn_row <- dplyr::filter(
      result_list$specialty_summary,
      specialty_group == "OB/GYN"
    )
    # FPMRS provider 1001 has mean annual volume 11.5 and is not low-volume
    expect_equal(fpmrs_row$n_low_volume_providers, 0L)
    # 1 unique OB/GYN provider was ever low-volume (NPI 1002 in both years)
    expect_equal(obgyn_row$n_low_volume_providers, 1L)
    # Total unique providers: 1 FPMRS, 1 OB/GYN
    expect_equal(fpmrs_row$n_providers, 1L)
    expect_equal(obgyn_row$n_providers, 1L)
  }
)

test_that("safe reporting helpers return NA rows instead of erroring on missing groups", {
  provider_vol <- tibble::tibble(
    Rndrng_NPI = c("1001", "1002"),
    specialty_group = c("OB/GYN", "OB/GYN"),
    annual_sling_count = c(12L, 18L)
  )

  pairwise_tidy <- safe_pairwise_wilcox_tidy(provider_vol)
  chisq_tidy <- safe_low_volume_chisq_tidy(
    provider_vol,
    low_volume_threshold = 10L
  )

  expect_equal(nrow(pairwise_tidy), 1L)
  expect_true(is.na(pairwise_tidy$p.value))
  expect_match(pairwise_tidy$test, "not computed")

  expect_equal(nrow(chisq_tidy), 1L)
  expect_true(is.na(chisq_tidy$p.value))
  expect_match(chisq_tidy$test, "not computed")
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
    -volume_tier
  )
  expect_error(
    validate_reporting_analysis_output(bad_result),
    regexp = "volume_tier"
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
    low_volume_threshold = 10L,
    time_trends_tbl = result_list$time_trends,
    year_col = "year"
  )

  expect_true(
    all(c("test", "statistic", "df", "p_value", "p_formatted") %in% names(stats_table))
  )
  expect_true(any(stats_table$test == "Kruskal-Wallis: annual volume across specialty groups"))
  expect_true(any(stats_table$test == "Chi-square: proportion low-volume across specialties"))
  expect_true(any(stats_table$test == "Linear regression: OB/GYN market share ~ year"))
})

test_that("build_focal_stats_table handles missing focal specialty without error", {
  provider_vol <- tibble::tibble(
    Rndrng_NPI = c("1001", "1002"),
    specialty_group = c("OB/GYN", "OB/GYN"),
    annual_sling_count = c(12L, 18L),
    volume_tier = c("Medium (10–24/yr)", "Medium (10–24/yr)")
  )

  stats_table <- build_focal_stats_table(
    provider_vol,
    low_volume_threshold = 10L
  )

  wilcox_row <- dplyr::filter(
    stats_table,
    test == "Wilcoxon (Bonferroni): OB/GYN vs Urology"
  )
  chisq_row <- dplyr::filter(
    stats_table,
    test == "Chi-square: proportion low-volume across specialties"
  )

  expect_equal(nrow(wilcox_row), 1L)
  expect_equal(wilcox_row$p_formatted, "NA (not computed)")
  expect_equal(nrow(chisq_row), 1L)
  expect_equal(chisq_row$p_formatted, "NA (not computed)")
})

test_that("generate_sling_abstract handles non-computable chi-square and trend tests", {
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
    low_volume_threshold = 10L,
    verbose = FALSE
  )

  abstract_result <- generate_sling_abstract(
    sling_analysis_output = result_list,
    low_volume_threshold = 10L,
    year_col = "year",
    study_years = c(2021L, 2022L),
    verbose = FALSE
  )

  chisq_row <- dplyr::filter(
    abstract_result$stats_table,
    test == "Chi-square: proportion low-volume across specialties"
  )
  trend_row <- dplyr::filter(
    abstract_result$stats_table,
    test == "Linear regression: OB/GYN market share ~ year"
  )

  expect_equal(chisq_row$p_formatted, "NA (not computed)")
  expect_equal(trend_row$p_formatted, "NA (not computed)")
  expect_true(is.na(abstract_result$filled_values$chi_square_p))
  expect_true(is.na(abstract_result$filled_values$obgyn_trend_p))
})

test_that("low-volume definition stays consistent across summary burden and abstract", {
  result_list <- analyze_midurethral_sling_patterns(
    make_puf_multiyear(),
    year_col = "year",
    low_volume_threshold = 10L,
    verbose = FALSE
  )
  abstract_result <- generate_sling_abstract(
    sling_analysis_output = result_list,
    low_volume_threshold = 10L,
    year_col = "year",
    study_years = c(2020L, 2022L),
    verbose = FALSE
  )

  burden_low_counts <- result_list$low_volume_burden |>
    dplyr::filter(is_low_volume_provider) |>
    dplyr::select(specialty_group, burden_n_low = n_providers)
  comparison <- result_list$specialty_summary |>
    dplyr::select(
      specialty_group,
      summary_n_low = n_low_volume_providers,
      summary_pct_low = pct_low_volume_providers
    ) |>
    dplyr::left_join(burden_low_counts, by = "specialty_group") |>
    dplyr::mutate(burden_n_low = dplyr::coalesce(burden_n_low, 0L))

  expect_true(all(comparison$summary_n_low == comparison$burden_n_low))

  obgyn_summary <- dplyr::filter(
    result_list$specialty_summary,
    specialty_group == "OB/GYN"
  )
  urology_summary <- dplyr::filter(
    result_list$specialty_summary,
    specialty_group == "Urology"
  )

  expect_equal(
    abstract_result$filled_values$obgyn_pct_low_volume,
    obgyn_summary$pct_low_volume_providers
  )
  expect_equal(
    abstract_result$filled_values$urology_pct_low_volume,
    urology_summary$pct_low_volume_providers
  )
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

  expect_error(
    manifest_verify(cache_dir, verbose = FALSE),
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
  allowed_specialty_groups <- c("FPMRS", "OB/GYN", "Urology", "Other")
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

test_that("main function: low_volume_burden has required columns", {
  result_list <- analyze_midurethral_sling_patterns(
    medicare_puf_data = make_minimal_puf(),
    verbose           = FALSE
  )
  required_columns <- c(
    "specialty_group", "is_low_volume_provider",
    "n_providers", "total_slings", "pct_of_all_slings"
  )
  expect_true(
    all(required_columns %in% names(result_list$low_volume_burden))
  )
})

test_that(
  paste0(
    "Invariant: low_volume_burden n_providers does not double-count ",
    "providers across TRUE/FALSE strata (multi-year)"
  ),
  {
    # In multi-year mode, a provider low-volume in 2020 and high-volume in
    # 2021 must appear in exactly ONE stratum, not both. If both strata
    # claim it, the sum across strata exceeds specialty_summary$n_providers.
    result_list <- analyze_midurethral_sling_patterns(
      make_puf_multiyear(), year_col = "year", verbose = FALSE
    )
    # For each specialty, sum of n_providers across burden strata must equal
    # n_providers from specialty_summary (each NPI in exactly one stratum).
    burden_by_specialty <- result_list$low_volume_burden |>
      dplyr::group_by(specialty_group) |>
      dplyr::summarise(
        burden_n_total = sum(n_providers, na.rm = TRUE),
        .groups = "drop"
      )
    summary_by_specialty <- result_list$specialty_summary |>
      dplyr::select(specialty_group, n_providers)
    comparison <- dplyr::left_join(
      burden_by_specialty,
      summary_by_specialty,
      by = "specialty_group"
    )
    expect_true(
      all(comparison$burden_n_total == comparison$n_providers),
      label = paste0(
        "Low-volume burden n_providers does not match specialty_summary ",
        "n_providers — providers are being double-counted across strata."
      )
    )
  }
)
