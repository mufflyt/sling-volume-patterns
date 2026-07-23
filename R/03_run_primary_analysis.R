# =============================================================================
# 03_run_primary_analysis.R
#
# Step 3: Run the primary analysis with concentration metrics.
# Reads puf_classified.rds, calls analyze_midurethral_sling_patterns(),
# writes sub-artifacts.
#
# Phase chain:
#   READS:  data/cache/puf_classified.rds   [Phase 2 artifact]
#   WRITES: data/cache/specialty_summary.rds
#           data/cache/provider_volume.rds
#           data/cache/concentration_metrics.rds
#           data/cache/time_trends.rds
#           data/cache/primary_analysis.rds  (combined list)
#
# Authors: Tyler Muffly, MD
# =============================================================================

source("R/artifact_manifest.R")
source("R/analyze_sling_patterns.R")
source("R/reporting_stats_helpers.R")

cfg          <- config::get()
phase_label  <- "03_primary_analysis"
phase_script <- "R/03_run_primary_analysis.R"

# ── Load Phase 2 artifact ────────────────────────────────────────────────
input_path     <- file.path(cfg$cache_dir, "puf_classified.rds")
puf_classified <- artifact_read(
  artifact_name = "puf_classified",
  file_path     = input_path,
  cache_dir     = cfg$cache_dir,
  verify_hash   = TRUE,
  verbose       = cfg$verbose
)

message(glue::glue(
  "[{format(Sys.time(), '%Y-%m-%d %H:%M:%S')}] ",
  "[03] Loaded puf_classified: {format(nrow(puf_classified), big.mark = ',')} rows."
))

# ── Run primary analysis ─────────────────────────────────────────────────
# cfg$urps_urology_npi_csv is optional; config::get() returns NULL when the
# key is absent, which analyze_*() treats as "keep urology-URPS in Urology".
results <- analyze_midurethral_sling_patterns(
  medicare_puf_data     = puf_classified,
  year_col              = cfg$year_col_name,
  concentration_cutoffs = cfg$concentration_cutoffs,
  verbose               = cfg$verbose,
  abog_npi_csv          = cfg$abog_npi_csv,
  urps_urology_npi_csv  = cfg$urps_urology_npi_csv,
  exclude_years         = cfg$exclude_years,
  other_handling        = "separate",
  split_urps_pathway    = TRUE
)
validate_reporting_analysis_output(
  results,
  year_col = cfg$year_col_name
)

# ── Write sub-artifacts ──────────────────────────────────────────────────
sub_artifacts <- list(
  specialty_summary     = results$specialty_summary,
  provider_volume       = results$provider_volume,
  concentration_metrics = results$concentration_metrics,
  time_trends           = results$time_trends,
  annual_concentration  = results$annual_concentration
)

for (name in names(sub_artifacts)) {
  if (is.null(sub_artifacts[[name]])) next  # e.g. annual_concentration in cross-sectional mode
  artifact_write(
    object        = sub_artifacts[[name]],
    artifact_name = name,
    file_path     = file.path(cfg$cache_dir, paste0(name, ".rds")),
    phase         = phase_label,
    phase_script  = phase_script,
    cache_dir     = cfg$cache_dir,
    verbose       = cfg$verbose
  )
}

# Combined list artifact for convenience
artifact_write(
  object        = results,
  artifact_name = "primary_analysis",
  file_path     = file.path(cfg$cache_dir, "primary_analysis.rds"),
  phase         = phase_label,
  phase_script  = phase_script,
  cache_dir     = cfg$cache_dir,
  verbose       = cfg$verbose
)

message(glue::glue(
  "[{format(Sys.time(), '%Y-%m-%d %H:%M:%S')}] [03] Complete. ",
  "{nrow(results$specialty_summary)} specialty groups, ",
  "{nrow(results$provider_volume)} provider-year rows."
))
