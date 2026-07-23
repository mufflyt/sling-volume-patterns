# =============================================================================
# test-review-fixes.R
#
# One test (or group) per confirmed issue from the second-round peer review, so
# a regression that reintroduces any bug fails loudly. Concern numbers match the
# review. Unit tests use synthetic data and always run; integration tests need
# the frozen puf_classified cache and skip gracefully when it is absent.
# =============================================================================

# ---- Unit tests: concentration metrics (reviewer #3, #8) --------------------

test_that("normalized HHI is 0 for equal volumes and rises with concentration", {
  expect_equal(compute_normalized_hhi(rep(10, 50)), 0, tolerance = 1e-9)
  expect_gt(compute_normalized_hhi(c(100, rep(1, 49))),
            compute_normalized_hhi(rep(10, 50)))
  expect_true(is.na(compute_normalized_hhi(5)))          # undefined for n < 2
})

test_that("effective number of providers equals N when volumes are equal", {
  expect_equal(compute_effective_providers(rep(7, 20)), 20, tolerance = 1e-9)
  expect_lt(compute_effective_providers(c(100, rep(1, 19))), 20)
})

test_that("bootstrap CI returns a finite interval bracketing the point estimate", {
  set.seed(1); x <- rpois(200, 20) + 1
  ci <- bootstrap_concentration_ci(x, compute_gini, R = 300L)
  expect_length(ci, 2)
  expect_true(all(is.finite(ci)))
  expect_lt(ci[1], ci[2])
  expect_true(ci[1] <= compute_gini(x) && compute_gini(x) <= ci[2])
})

# ---- Unit tests: classification (reviewer #1) -------------------------------

test_that("facilities and non-physicians are NOT classified as urology", {
  # reviewer #1: ambulatory surgical centers, PAs, NPs are not urologists.
  expect_equal(classify_provider_specialty("Ambulatory Surgical Center"), "Other")
  expect_equal(classify_provider_specialty("Physician Assistant"), "Other")
  expect_equal(classify_provider_specialty("Nurse Practitioner"), "Other")
  expect_equal(classify_provider_specialty("Urology"), "Urology")
  expect_equal(classify_provider_specialty("Obstetrics & Gynecology"), "OB/GYN")
  expect_equal(classify_provider_specialty("Female Pelvic Medicine and Reconstructive Surgery"), "URPS")
})

# ---- Unit tests: models (reviewer #4, #12) ----------------------------------

test_that("specialty_year_slopes returns one marginal slope per specialty", {
  set.seed(2)
  yrs <- 2018:2022                          # span includes 2020 (COVID column)
  d <- data.frame(
    Rndrng_NPI = factor(rep(1:80, each = length(yrs))),
    specialty_group = rep(c("URPS", "Urology"), each = 40 * length(yrs)),
    puf_year = rep(yrs, times = 80),
    annual_sling_count = rpois(80 * length(yrs), 15) + 1)
  g <- fit_volume_gee(d, year_col = "puf_year", reference_specialty = "URPS", verbose = FALSE)
  skip_if(is.null(g), "geepack unavailable")
  sl <- specialty_year_slopes(g$model, reference_specialty = "URPS")
  expect_setequal(sl$specialty, c("URPS", "Urology"))
  expect_true(all(c("slope_rr", "ci_low", "ci_high", "p_value") %in% names(sl)))
})

test_that("quasibinomial URPS-share model returns an odds ratio and pp/year", {
  d <- data.frame(year = 2013:2023,
                  urps_services = round(seq(500, 700, length.out = 11)),
                  total_services = 1000)
  b <- fit_urps_share_binomial(d, center_year = 2018)
  expect_true(b$or_per_year > 1)          # rising share
  expect_true(b$pp_per_year > 0)
  expect_length(b$or_ci, 2)
})

# ---- Unit tests: denominator / rate (reviewer #2, #5) -----------------------

test_that("attach_ffs_rate computes services per 100,000", {
  den <- data.frame(year = 2013L, denominator = 1e6)
  out <- attach_ffs_rate(data.frame(year = 2013L, services = 50),
                         year_col = "year", services_col = "services", denom = den)
  expect_equal(out$rate_per_100k, 5, tolerance = 1e-9)   # 50 / 1e6 * 1e5
})

test_that("the female Part B FFS denominator file exists and shrinks over time", {
  .root <- normalizePath(testthat::test_path("..", ".."))
  den <- read_ffs_denominator(file.path(.root, "data", "denominator", "female_ffs_denominator.csv"))
  skip_if(is.null(den), "denominator file not available")
  expect_true(all(c(2013, 2023) %in% den$year))
  d13 <- den$denominator[den$year == 2013]; d23 <- den$denominator[den$year == 2023]
  expect_gt(d13, d23)                                    # FFS population contracted
  expect_lt(d23 / d13, 0.95)                             # by > 5%
})

# ---- Integration tests against the frozen cache -----------------------------
# testthat runs with wd = tests/testthat, so build absolute paths from the
# project root and evaluate cache-dependent code there.

.root  <- normalizePath(testthat::test_path("..", ".."))
.puf   <- file.path(.root, "data", "cache", "puf_classified.rds")
.abog  <- file.path(.root, "data", "canonical_abog", "canonical_abog_npi_LATEST.csv")
.abu   <- file.path(.root, "data", "abu_urology", "abu_urps_npi_LATEST.csv")
with_root <- function(expr) { old <- setwd(.root); on.exit(setwd(old)); force(expr) }

test_that("other_handling separates facilities/Other from urology (reviewer #1)", {
  skip_if_not(file.exists(.puf), "puf_classified cache not available")
  pc <- readRDS(.puf)
  sep <- with_root(analyze_midurethral_sling_patterns(pc, year_col = "puf_year",
           abog_npi_csv = .abog, urps_urology_npi_csv = .abu,
           other_handling = "separate", verbose = FALSE))
  leg <- with_root(analyze_midurethral_sling_patterns(pc, year_col = "puf_year",
           abog_npi_csv = .abog, urps_urology_npi_csv = .abu,
           other_handling = "urology", verbose = FALSE))
  sp <- sep$provider_volume; lg <- leg$provider_volume
  # An "Other/uncertain" group exists under the primary handling...
  expect_true("Other/uncertain" %in% sp$specialty_group)
  # ...and is absent under the legacy urology handling.
  expect_false("Other/uncertain" %in% lg$specialty_group)
  uro_sep <- dplyr::n_distinct(sp$Rndrng_NPI[sp$specialty_group == "Urology"])
  uro_leg <- dplyr::n_distinct(lg$Rndrng_NPI[lg$specialty_group == "Urology"])
  # The legacy rule roughly doubled the urology count by absorbing non-urologists.
  expect_gt(uro_leg, uro_sep * 1.5)
  # The audit records facility exclusions, and the legacy run does not.
  expect_gt(sep$classification_audit$excluded_facility_npis, 0)
  # Reclassification removed real services from urology (facilities/non-physicians).
  uro_svc_sep <- sum(sp$annual_sling_count[sp$specialty_group == "Urology"])
  uro_svc_leg <- sum(lg$annual_sling_count[lg$specialty_group == "Urology"])
  expect_gt(uro_svc_leg, uro_svc_sep * 1.3)
})

# Compute manuscript values once; heavy, so memoize at file scope.
.mv <- NULL
get_mv <- function() {
  if (!is.null(.mv)) return(.mv)
  skip_if_not(file.exists(.puf), "puf_classified cache not available")
  suppressWarnings(suppressMessages(with_root({
    source(file.path(.root, "R", "compute_manuscript_values.R"))
    .mv <<- compute_manuscript_values(.puf)
  })))
  .mv
}

test_that("abstract within-year Gini uses ANNUAL not pooled values (reviewer #7)", {
  v <- get_mv()$v
  ay_urps <- as.numeric(v$annual_gini_urps)   # within-year, ~0.28
  po_urps <- v$urps_gini                       # pooled, ~0.52
  expect_lt(ay_urps, 0.35)
  expect_gt(po_urps, 0.45)
  expect_lt(ay_urps, po_urps - 0.15)           # annual clearly below pooled
})

test_that("pairwise Gini differences are tested, not inferred from overlap (reviewer #8)", {
  v <- get_mv()$v
  # URPS vs other OB/GYN differ (CI excludes 0); URPS vs urology do not.
  expect_true(v$ginidiff_urps_gob$differs)
  expect_false(v$ginidiff_urps_uro$differs)
  # effective-provider fraction reported and a gradient present
  expect_true(v$urps_effpct > v$gob_effpct)
})

test_that("utilization uses a denominator-offset model with an estimate + CI (reviewer #5/#6)", {
  v <- get_mv()$v
  skip_if(is.null(v$rate_offset_rr), "denominator unavailable")
  expect_lt(as.numeric(v$rate_offset_rr), 1)          # declining point estimate
  expect_true(nzchar(v$rate_offset_ci))               # CI reported
  expect_true(nzchar(v$rate_offset_decade))           # decade effect reported
})

test_that("negative-binomial sensitivity is reported with numbers (reviewer #11)", {
  v <- get_mv()$v
  skip_if(!isTRUE(v$has_nb), "glmmTMB unavailable")
  expect_true(nzchar(v$nb_urology) && nzchar(v$nb_gob))
  # GEE and NB give materially different magnitudes (marginal vs conditional)
  gee_uro <- as.numeric(sub(" .*", "", v$gee_urology))
  nb_uro  <- as.numeric(sub(" .*", "", v$nb_urology))
  expect_gt(abs(nb_uro - gee_uro), 0.03)
})

test_that("quasibinomial share model is available as the headline (reviewer #12)", {
  v <- get_mv()$v
  expect_true(isTRUE(v$has_share_binom))
  expect_true(nzchar(v$share_binom_pp) && nzchar(v$share_binom_or))
})

test_that("Table 1 shows Other/uncertain and 'Other non-URPS OB/GYN' (reviewer #1/#2)", {
  mv <- get_mv()
  labs <- mv$tab$t1$Specialty
  expect_true("Other/uncertain" %in% labs)
  expect_true("Other non-URPS OB/GYN" %in% labs)
  expect_false("General OB/GYN" %in% labs)              # renamed
})

test_that("clean non-URPS urology share is far below the legacy inflated value (reviewer #1)", {
  v <- get_mv()$v
  expect_lt(v$uro_pct, 20)                              # ~14.5%, not 26.1%
  expect_true(v$other_phys > 0)                          # Other/uncertain populated
})

test_that("classification sensitivity table has all three handlings (reviewer #1)", {
  tab <- get_mv()$tab
  expect_equal(nrow(tab$t_classif_sens), 3)
})
