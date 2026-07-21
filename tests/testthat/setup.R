# setup.R — sourced automatically before tests run
# Load all core analysis functions so tests can call them.
#
# Several source files use project-root-relative source() calls internally
# (e.g. analyze_sling_patterns.R does source("R/reporting_stats_helpers.R")).
# testthat runs with the working directory set to tests/testthat, so those
# relative paths would not resolve. Source everything with the working
# directory temporarily set to the project root; the function definitions
# still land in this (test) environment, and no relative path can escape.
.proj_root <- normalizePath(testthat::test_path("..", ".."))
.old_wd <- setwd(.proj_root)
source(file.path(.proj_root, "R", "artifact_manifest.R"))
source(file.path(.proj_root, "R", "reporting_stats_helpers.R"))
source(file.path(.proj_root, "R", "analyze_sling_patterns.R"))
source(file.path(.proj_root, "R", "generate_sling_abstract.R"))
source(file.path(.proj_root, "R", "volume_models.R"))
setwd(.old_wd)
rm(.proj_root, .old_wd)
