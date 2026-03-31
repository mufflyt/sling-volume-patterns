# =============================================================================
# 04_run_sensitivity_analyses.R
#
# Step 4: Iterate the primary analysis over every combination of
# (low_volume_threshold × year_mode) using expand.grid()
# and purrr::map() |> dplyr::bind_rows().  Produces a single tidy sensitivity table that
# supports the "reviewer will ask about the threshold choice" response.
#
# Pattern from ferenci-tamas/MortalityPrediction (BMC MRM 2023):
#   pargrid <- expand.grid(...)
#   results <- sapply(1:nrow(pargrid), function(i) analyze(...pargrid[i,]))
#
# Input:  data/cache/puf_classified.rds  (written by 02_classify_specialties.R)
# Output: data/cache/sensitivity_results.rds
#         output/tables/sensitivity_table.csv
#
# Authors: Tyler Muffly, MD
# =============================================================================

source("R/analyze_sling_patterns.R")
# Bug fix B5: source("R/generate_sling_abstract.R") was here but no
# function from that file is called in this script. Removed dead import.

cfg <- config::get()

# ── Load classified cache ──────────────────────────────────────────────────
classified_cache_path <- file.path(cfg$cache_dir, "puf_classified.rds")
assertthat::assert_that(
  file.exists(classified_cache_path),
  msg = glue::glue(
    "Classified cache not found: {classified_cache_path}. ",
    "Run 02_classify_specialties.R first."
  )
)
puf_classified <- readRDS(classified_cache_path)
message(glue::glue(
  "[{format(Sys.time(), '%Y-%m-%d %H:%M:%S')}] ",
  "Loaded classified cache: {format(nrow(puf_classified), big.mark = ',')} rows."
))

# ── Guard the config.yml coupling invariant ──────────────────────────────
# Bug fix B7 (runtime guard): config.yml documents the invariant that
# low_volume_threshold_primary must appear in sensitivity_thresholds.
# Enforce it here so a config change produces a clear error rather than
# silent all-NA deltas downstream.
assertthat::assert_that(
  cfg$low_volume_threshold_primary %in% cfg$sensitivity_thresholds,
  msg = glue::glue(
    "config.yml invariant violated: low_volume_threshold_primary ",
    "({cfg$low_volume_threshold_primary}) must appear in sensitivity_thresholds ",
    "({paste(cfg$sensitivity_thresholds, collapse = ', ')}). ",
    "Add {cfg$low_volume_threshold_primary} to sensitivity_thresholds or ",
    "update low_volume_threshold_primary to match a value already in the list."
  )
)

# ── Build analysis grid ───────────────────────────────────────────────────
# Every combination of (year_mode × threshold) to iterate.
# year_mode: "cross_sectional" uses the most recent year only;
#            "multi_year" uses all puf_years from config.yml.
sensitivity_grid <- expand.grid(
  low_volume_threshold = cfg$sensitivity_thresholds,
  year_mode            = c("cross_sectional", "multi_year"),
  stringsAsFactors     = FALSE
)

message(glue::glue(
  "[{format(Sys.time(), '%Y-%m-%d %H:%M:%S')}] ",
  "Sensitivity grid: {nrow(sensitivity_grid)} combinations to run."
))
message("  threshold × year_mode:")
purrr::walk(
  seq_len(nrow(sensitivity_grid)),
  function(i) {
    message(glue::glue(
      "    [{i}] threshold={sensitivity_grid$low_volume_threshold[i]}, ",
      "mode={sensitivity_grid$year_mode[i]}"
    ))
  }
)

# ── Helper: run one grid cell ─────────────────────────────────────────────
run_one_sensitivity_cell <- function(
    grid_row_index,
    grid,
    puf_data,
    cfg_obj
) {
  threshold  <- grid$low_volume_threshold[grid_row_index]
  year_mode  <- grid$year_mode[grid_row_index]

  message(glue::glue(
    "  [{grid_row_index}/{nrow(grid)}] threshold={threshold}, mode={year_mode}"
  ))

  # Filter to the appropriate year set
  # Bug fix B1: `puf_year` was hardcoded for the cross-sectional filter.
  # The same coupling fix (B5 last session) was applied to year_col_arg on
  # line 108 but missed here. If year_col_name changes in config.yml, this
  # filter silently returned 0 rows with no error.
  analysis_data <- if (year_mode == "cross_sectional") {
    most_recent_year <- max(cfg_obj$puf_years)
    dplyr::filter(puf_data, .data[[cfg_obj$year_col_name]] == most_recent_year)
  } else {
    puf_data
  }

  # Bug fix B5: "puf_year" was hardcoded. The identical fix (B8 from the
  # previous session) was applied to 05_generate_abstract.R but missed here.
  # If cfg$year_col_name changes in config.yml, this would silently pass the
  # wrong column name to analyze_midurethral_sling_patterns().
  year_col_arg <- if (year_mode == "multi_year") cfg_obj$year_col_name else NULL

  # Run the main analysis function
  analysis_results <- analyze_midurethral_sling_patterns(
    medicare_puf_data    = analysis_data,
    year_col             = year_col_arg,
    low_volume_threshold = threshold,
    verbose              = FALSE
  )

  # Flatten specialty_summary to one tidy row per specialty group
  analysis_results$specialty_summary |>
    dplyr::mutate(
      sensitivity_threshold = threshold,
      sensitivity_year_mode = year_mode,
      sensitivity_cell_id   = grid_row_index
    )
}

# ── Iterate over all grid cells ─────────────────────────────────────────────
# Pattern 2 (mkiang/excess_physician_mortality): furrr::future_map() mirrors
# purrr::map() exactly but uses the parallel backend set by future::plan().
# When cfg$proc_in_parallel == TRUE, cells run in parallel across num_cores
# workers. When FALSE, future::plan(sequential) gives identical serial
# behaviour to the original purrr::map() call — zero overhead, zero risk.
# furrr_options(seed=) ensures reproducible results regardless of worker
# scheduling order.
if (isTRUE(cfg$proc_in_parallel) && cfg$num_cores > 1L) {
  future::plan(future::multisession, workers = cfg$num_cores)
  message(glue::glue(
    "[{format(Sys.time(), '%Y-%m-%d %H:%M:%S')}] ",
    "Parallel plan: multisession with {cfg$num_cores} workers."
  ))
} else {
  future::plan(future::sequential)
  message(glue::glue(
    "[{format(Sys.time(), '%Y-%m-%d %H:%M:%S')}] ",
    "Parallel plan: sequential (set proc_in_parallel: true in config.yml ",
    "to enable multisession parallelisation)."
  ))
}

sensitivity_results <- furrr::future_map(
  seq_len(nrow(sensitivity_grid)),
  \(i) run_one_sensitivity_cell(
    i,
    grid     = sensitivity_grid,
    puf_data = puf_classified,
    cfg_obj  = cfg
  ),
  .options = furrr::furrr_options(seed = cfg$seed)
) |>
  dplyr::bind_rows()

# Always restore sequential plan after the sweep so downstream code
# in the same session is not accidentally parallelised.
future::plan(future::sequential)

message(glue::glue(
  "[{format(Sys.time(), '%Y-%m-%d %H:%M:%S')}] ",
  "Sensitivity sweep complete: {nrow(sensitivity_results)} result rows."
))

# Bug fix B3: assert non-empty before computing deltas.
# If puf_classified is empty or every grid cell errored, map() |> bind_rows()
# returns a 0-row tibble. The delta computation would succeed silently and
# write an empty CSV with no diagnostic.
assertthat::assert_that(
  nrow(sensitivity_results) > 0L,
  msg = glue::glue(
    "sensitivity_results has 0 rows after sweeping {nrow(sensitivity_grid)} ",
    "grid cells. Check that puf_classified.rds is non-empty and that ",
    "analyze_midurethral_sling_patterns() succeeds for at least one cell."
  )
)

# ── Compute pct change from primary threshold for comparison ──────────────
# Bug fix B7: the left_join needs exactly one primary row per specialty_group.
# Use dplyr::distinct() to guarantee uniqueness before joining, preventing
# duplicate rows if the primary threshold happens to appear in multiple
# result rows with slightly different floating-point values.
primary_pct_by_group <- sensitivity_results |>
  dplyr::filter(
    sensitivity_threshold == cfg$low_volume_threshold_primary,
    sensitivity_year_mode == "cross_sectional"
  ) |>
  dplyr::select(specialty_group, pct_low_volume_providers_primary = pct_low_volume_providers) |>
  dplyr::distinct(specialty_group, .keep_all = TRUE)

# Bug fix B3: the B7 config guard confirms low_volume_threshold_primary
# appears in the sensitivity_thresholds list, but does not guarantee
# that the sweep produced rows for that threshold + cross_sectional
# combination. If that cell failed silently or produced no data,
# primary_pct_by_group would be 0 rows, the join would produce an
# all-NA pct_low_vol_delta_from_primary column, and no error is raised.
assertthat::assert_that(
  nrow(primary_pct_by_group) > 0L,
  msg = glue::glue(
    "primary_pct_by_group has 0 rows after filtering sensitivity_results ",
    "to threshold={cfg$low_volume_threshold_primary}, mode=cross_sectional. ",
    "The sensitivity sweep must have failed for that cell. ",
    "Check that puf_classified.rds contains data for the most recent year."
  )
)

sensitivity_results <- sensitivity_results |>
  dplyr::left_join(primary_pct_by_group, by = "specialty_group") |>
  dplyr::mutate(
    pct_low_vol_delta_from_primary =
      pct_low_volume_providers - pct_low_volume_providers_primary
  )

# ── Cache and export ──────────────────────────────────────────────────────
sensitivity_cache_path <- file.path(cfg$cache_dir, "sensitivity_results.rds")
saveRDS(sensitivity_results, file = sensitivity_cache_path)
message(glue::glue(
  "  Cached: {sensitivity_cache_path}"
))

dir.create(cfg$tables_dir, recursive = TRUE, showWarnings = FALSE)
sensitivity_csv_path <- file.path(cfg$tables_dir, "sensitivity_table.csv")
readr::write_csv(sensitivity_results, sensitivity_csv_path)
message(glue::glue(
  "  Exported: {sensitivity_csv_path}"
))

# ── Console preview ───────────────────────────────────────────────────────
message("\nSensitivity table preview (pct_low_volume_providers by threshold × mode):")
sensitivity_results |>
  dplyr::select(
    specialty_group,
    sensitivity_threshold,
    sensitivity_year_mode,
    pct_low_volume_providers,
    pct_low_vol_delta_from_primary
  ) |>
  dplyr::arrange(
    sensitivity_threshold,
    sensitivity_year_mode,
    specialty_group
  ) |>
  print(n = Inf)
