# =============================================================================
# test-code-quality.R
#
# Guards for the code-health improvements:
#   #6  every `r v$name` referenced in the manuscript exists in the computed
#       value list (a typo fails here instead of rendering a blank).
#   #8  golden/snapshot regression on the headline numbers (any unintended
#       numeric change fails precisely, not just "out of range").
#   #4  the pipeline cache (step 03) and compute_manuscript_values() use the
#       same specialty grouping, so main and supplementary outputs cannot drift.
# =============================================================================

.root <- normalizePath(testthat::test_path("..", ".."))
.puf  <- file.path(.root, "data", "cache", "puf_classified.rds")

# Compute the manuscript values once (heavy); memoize at file scope.
.MV <- NULL
mv_once <- function() {
  if (!is.null(.MV)) return(.MV)
  skip_if_not(file.exists(.puf), "puf_classified cache not available")
  old <- setwd(.root); on.exit(setwd(old))
  suppressWarnings(suppressMessages({
    source(file.path(.root, "R", "compute_manuscript_values.R"))
    .MV <<- compute_manuscript_values(.puf)
  }))
  .MV
}

# ---- #6: the v dictionary covers every reference in the manuscript ----------

test_that("every v$ referenced in manuscript.Rmd exists in the value list", {
  rmd <- file.path(.root, "output", "manuscript.Rmd")
  skip_if_not(file.exists(rmd), "manuscript.Rmd not found")
  txt <- paste(readLines(rmd, warn = FALSE), collapse = "\n")
  # top-level name after v$ (nested access like v$urps_trend$slope -> urps_trend)
  refs <- unique(regmatches(txt, gregexpr("(?<![A-Za-z0-9_.])v\\$([A-Za-z0-9_]+)", txt, perl = TRUE))[[1]])
  refs <- sub("^v\\$", "", refs)
  refs <- setdiff(refs, "")                     # guard
  v <- mv_once()$v
  missing <- setdiff(refs, names(v))
  expect_true(length(missing) == 0,
    info = paste("v$ names referenced in the Rmd but not computed:",
                 paste(missing, collapse = ", ")))
})

# ---- #8: golden regression on the headline numbers --------------------------

test_that("headline manuscript numbers match the expected golden values", {
  v <- mv_once()$v
  # If the analysis intentionally changes, update these expected values.
  # Primary cohort excludes organizational NPIs (entity type 2) and the
  # Other/uncertain billers (other_handling = "exclude"): identified physicians
  # only, with Other/uncertain retained solely as a sensitivity.
  expect_equal(v$analytic_physicians, 1467)
  expect_equal(v$analytic_procs, 129517)
  expect_equal(v$urps_pct, 59.8, tolerance = 0.05)      # OB/GYN-pathway URPS
  expect_equal(v$urpsuro_pct, 9.5, tolerance = 0.05)    # urology-pathway URPS
  expect_equal(v$urps_combined_pct, 69.3, tolerance = 0.05)  # primary estimand
  expect_equal(v$uro_pct, 15.8, tolerance = 0.05)       # non-URPS urology
  expect_equal(v$gob_pct, 14.2, tolerance = 0.05)       # other non-URPS OB/GYN
  expect_equal(v$mig_pct, 0.7, tolerance = 0.05)
  # The five analyzed physician groups partition the primary cohort.
  expect_equal(v$urps_pct + v$urpsuro_pct + v$uro_pct + v$gob_pct + v$mig_pct,
               100.0, tolerance = 0.1)
  expect_equal(v$class_excluded_facility, 123)          # entity-type-2 orgs
})

test_that("Table 4 p-values are computed (not the old hardcoded strings)", {
  tab <- mv_once()$tab
  # The modal/ever rows used to be hardcoded; now they come from the fits and
  # must be valid formatted p-values, never NA/NaN.
  pv4 <- gsub("\\*", "", tab$t4$`p-value`)
  expect_true(all(pv4 %in% c("<0.001") | grepl("^[0-9]\\.[0-9]+$", pv4)))
  expect_false(any(grepl("n/a|NaN|NA", tab$t4$`p-value`)))
})

# ---- #4: pipeline cache and manuscript use the same grouping ----------------

test_that("cached provider_volume grouping matches compute_manuscript_values", {
  skip_if_not(file.exists(.puf), "puf_classified cache not available")
  pvfile <- file.path(.root, "data", "cache", "provider_volume.rds")
  skip_if_not(file.exists(pvfile), "cached provider_volume not available (run step 03)")
  cache_groups <- sort(unique(as.character(readRDS(pvfile)$specialty_group)))
  # groups the manuscript expects, from the central taxonomy
  old <- setwd(.root); on.exit(setwd(old))
  source(file.path(.root, "R", "specialty_groups.R"))
  source(file.path(.root, "R", "build_ffs_denominator.R"))
  taxo_groups <- sort(sg_codes("all"))
  # Every cached group must be a valid taxonomy code.
  expect_true(all(cache_groups %in% taxo_groups))
  # Under the primary "exclude" handling the Other/uncertain group is dropped
  # from the cohort, so the cache holds the five analyzed groups; under
  # "separate" it holds all six. Assert the cache matches the configured mode.
  expected <- if (identical(classification_opts()$other_handling, "exclude")) {
    setdiff(taxo_groups, "Other/uncertain")
  } else taxo_groups
  expect_equal(cache_groups, sort(expected))
})
