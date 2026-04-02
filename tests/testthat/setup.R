# setup.R — sourced automatically before tests run
# Load all core analysis functions so tests can call them
source(file.path(testthat::test_path("..", ".."), "R", "artifact_manifest.R"))
source(file.path(testthat::test_path("..", ".."), "R", "reporting_stats_helpers.R"))
source(file.path(testthat::test_path("..", ".."), "R", "analyze_sling_patterns.R"))
source(file.path(testthat::test_path("..", ".."), "R", "generate_sling_abstract.R"))
