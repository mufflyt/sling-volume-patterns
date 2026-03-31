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

cfg          <- config::get()
phase_label  <- "05_generate_abstract"
phase_script <- "R/05_generate_abstract.R"

# ── Load Phase 3 sub-artifacts ───────────────────────────────────────────
specialty_summary <- artifact_read(
  artifact_name = "specialty_summary",
  file_path     = file.path(cfg$cache_dir, "specialty_summary.rds"),
  cache_dir     = cfg$cache_dir,
  verify_hash   = TRUE,
  verbose       = cfg$verbose
)

provider_volume <- artifact_read(
  artifact_name = "provider_volume",
  file_path     = file.path(cfg$cache_dir, "provider_volume.rds"),
  cache_dir     = cfg$cache_dir,
  verify_hash   = TRUE,
  verbose       = cfg$verbose
)

time_trends <- artifact_read(
  artifact_name = "time_trends",
  file_path     = file.path(cfg$cache_dir, "time_trends.rds"),
  cache_dir     = cfg$cache_dir,
  verify_hash   = TRUE,
  verbose       = cfg$verbose
)

message(glue::glue(
  "[{format(Sys.time(), '%Y-%m-%d %H:%M:%S')}] ",
  "[05] Generating abstract text..."
))

# ── Generate abstract ───────────────────────────────────────────────────
abstract_text <- generate_sling_abstract(
  specialty_summary    = specialty_summary,
  provider_volume      = provider_volume,
  time_trends          = time_trends,
  low_volume_threshold = cfg$low_volume_threshold_primary,
  year_col             = cfg$year_col_name,
  study_start_year     = cfg$study_start_year,
  study_end_year       = cfg$study_end_year,
  verbose              = cfg$verbose
)

# ── Write output ────────────────────────────────────────────────────────
dir.create(cfg$output_dir, recursive = TRUE, showWarnings = FALSE)
abstract_path <- file.path(cfg$output_dir, "abstract.txt")
writeLines(abstract_text, con = abstract_path)

message(glue::glue(
  "[{format(Sys.time(), '%Y-%m-%d %H:%M:%S')}] ",
  "[05] Abstract written: {abstract_path} ",
  "({nchar(abstract_text)} characters)"
))
