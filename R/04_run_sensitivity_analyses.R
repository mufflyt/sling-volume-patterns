# =============================================================================
# 04_run_sensitivity_analyses.R
#
# Step 4: Sensitivity analysis — compute concentration metrics under
# cross-sectional (most recent year only) vs multi-year modes.
#
# Input:  data/cache/puf_classified.rds  (written by 02_classify_specialties.R)
# Output: data/cache/sensitivity_results.rds
#         output/tables/sensitivity_table.csv
#
# Authors: Tyler Muffly, MD
# =============================================================================

source("R/analyze_sling_patterns.R")

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

# ── Build analysis grid ───────────────────────────────────────────────────
sensitivity_grid <- expand.grid(
  year_mode        = c("cross_sectional", "multi_year"),
  stringsAsFactors = FALSE
)

message(glue::glue(
  "[{format(Sys.time(), '%Y-%m-%d %H:%M:%S')}] ",
  "Sensitivity grid: {nrow(sensitivity_grid)} combinations to run."
))

# ── Helper: run one grid cell ─────────────────────────────────────────────
run_one_sensitivity_cell <- function(
    grid_row_index,
    grid,
    puf_data,
    cfg_obj
) {
  year_mode  <- grid$year_mode[grid_row_index]

  message(glue::glue(
    "  [{grid_row_index}/{nrow(grid)}] mode={year_mode}"
  ))

  analysis_data <- if (year_mode == "cross_sectional") {
    most_recent_year <- max(cfg_obj$puf_years)
    dplyr::filter(puf_data, .data[[cfg_obj$year_col_name]] == most_recent_year)
  } else {
    puf_data
  }

  year_col_arg <- if (year_mode == "multi_year") cfg_obj$year_col_name else NULL

  analysis_results <- analyze_midurethral_sling_patterns(
    medicare_puf_data     = analysis_data,
    year_col              = year_col_arg,
    concentration_cutoffs = cfg_obj$concentration_cutoffs,
    verbose               = FALSE
  )

  # Return specialty summary with concentration metrics
  analysis_results$specialty_summary |>
    dplyr::mutate(
      sensitivity_year_mode = year_mode,
      sensitivity_cell_id   = grid_row_index
    )
}

# ── Iterate over all grid cells ─────────────────────────────────────────────
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

future::plan(future::sequential)

message(glue::glue(
  "[{format(Sys.time(), '%Y-%m-%d %H:%M:%S')}] ",
  "Sensitivity sweep complete: {nrow(sensitivity_results)} result rows."
))

assertthat::assert_that(
  nrow(sensitivity_results) > 0L,
  msg = glue::glue(
    "sensitivity_results has 0 rows after sweeping {nrow(sensitivity_grid)} ",
    "grid cells. Check that puf_classified.rds is non-empty."
  )
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
message("\nSensitivity table preview (Gini by year_mode):")
sensitivity_results |>
  dplyr::select(
    specialty_group,
    sensitivity_year_mode,
    gini_coefficient,
    pct_of_all_slings
  ) |>
  dplyr::arrange(
    sensitivity_year_mode,
    specialty_group
  ) |>
  print(n = Inf)
