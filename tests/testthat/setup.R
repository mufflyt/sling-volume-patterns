# setup.R — sourced automatically before tests run
# Load all core analysis functions so tests can call them
source(file.path(testthat::test_path("..", ".."), "R", "analyze_sling_patterns.R"))
