# =============================================================================
# 05_generate_abstract.R
#
# Step 5: Generate the AUGS abstract with programmatic statistics.
# Reads Phase 3 artifacts, calls generate_sling_abstract(), writes abstract
# text to output/abstract.txt.
#
# Phase chain:
#   READS:  data/cache/specialty_summary.rds  [Phase 3 sub-artifact]
#           data/cache/provider_volume.rds    [Phase 3 sub-artifact]
#           data/cache/time_trends.rds        [Phase 3 sub-artifact]
#   WRITES: output/abstract.txt
#
# Authors: Tyler Muffly, MD
# =============================================================================

source("R/artifact_manifest.R")
source("R/generate_sling_abstract.R")
source("R/reporting_stats_helpers.R")

cfg          <- config::get()
phase_label  <- "05_generate_abstract"
phase_script <- "R/05_generate_abstract.R"

# ── Load Phase 3 combined artifact ─────────────────────────────────────
primary_analysis <- artifact_read(
  artifact_name = "primary_analysis",
  file_path     = file.path(cfg$cache_dir, "primary_analysis.rds"),
  cache_dir     = cfg$cache_dir,
  verify_hash   = TRUE,
  verbose       = cfg$verbose
)
validate_reporting_analysis_output(
  primary_analysis,
  year_col = cfg$year_col_name,
  required_specialty_groups = c("Urology")
)

message(glue::glue(
  "[{format(Sys.time(), '%Y-%m-%d %H:%M:%S')}] ",
  "[05] Generating abstract text..."
))

# ── Generate abstract ───────────────────────────────────────────────────
# generate_sling_abstract() expects the full analysis list (output of
# analyze_midurethral_sling_patterns()) containing: provider_volume,
# specialty_summary, low_volume_burden, time_trends.
abstract_result <- generate_sling_abstract(
  sling_analysis_output = primary_analysis,
  year_col              = cfg$year_col_name,
  study_years           = c(cfg$study_start_year, cfg$study_end_year),
  verbose               = cfg$verbose
)

# generate_sling_abstract() returns a list with abstract_text, stats_table,
# and filled_values. Extract the text for writing.
abstract_text <- abstract_result$abstract_text

# ── Write output ────────────────────────────────────────────────────────
dir.create(cfg$output_dir, recursive = TRUE, showWarnings = FALSE)
abstract_path <- file.path(cfg$output_dir, "abstract.txt")
writeLines(abstract_text, con = abstract_path)

# Also save the full result (stats_table + filled_values) for downstream use
artifact_write(
  object        = abstract_result,
  artifact_name = "abstract_result",
  file_path     = file.path(cfg$cache_dir, "abstract_result.rds"),
  phase         = phase_label,
  phase_script  = phase_script,
  cache_dir     = cfg$cache_dir,
  verbose       = cfg$verbose
)

message(glue::glue(
  "[{format(Sys.time(), '%Y-%m-%d %H:%M:%S')}] ",
  "[05] Abstract written: {abstract_path} ",
  "({nchar(abstract_text)} characters)"
))
