# =============================================================================
# 02_classify_specialties.R
#
# Step 2: Read puf_merged.rds, classify each provider's specialty using the
# hierarchical regex taxonomy (FPMRS > OB/GYN > Urology > Other), write
# data/cache/puf_classified.rds.
#
# Phase chain:
#   READS:  data/cache/puf_merged.rds      [Phase 1 artifact]
#   WRITES: data/cache/puf_classified.rds
#
# Authors: Tyler Muffly, MD
# =============================================================================

source("R/artifact_manifest.R")
source("R/analyze_sling_patterns.R")

cfg          <- config::get()
phase_label  <- "02_classify_specialties"
phase_script <- "R/02_classify_specialties.R"

# ── Load Phase 1 artifact ────────────────────────────────────────────────
input_path <- file.path(cfg$cache_dir, "puf_merged.rds")
puf_merged <- artifact_read(
  artifact_name = "puf_merged",
  file_path     = input_path,
  cache_dir     = cfg$cache_dir,
  verify_hash   = TRUE,
  verbose       = cfg$verbose
)

message(glue::glue(
  "[{format(Sys.time(), '%Y-%m-%d %H:%M:%S')}] ",
  "[02] Loaded puf_merged: {format(nrow(puf_merged), big.mark = ',')} rows."
))

# ── Classify specialties ─────────────────────────────────────────────────
# Uses classify_provider_specialty() from analyze_sling_patterns.R
# Hierarchy: FPMRS > OB/GYN > Urology > Other
puf_classified <- dplyr::mutate(
  puf_merged,
  specialty_group = classify_provider_specialty(Rndrng_Prvdr_Type)
)

# Log distribution
specialty_counts <- dplyr::count(puf_classified, specialty_group, sort = TRUE)
message("[02] Specialty classification distribution:")
purrr::walk(seq_len(nrow(specialty_counts)), function(i) {
  message(glue::glue(
    "    {specialty_counts$specialty_group[i]}: ",
    "{format(specialty_counts$n[i], big.mark = ',')} rows"
  ))
})

# ── Write artifact ──────────────────────────────────────────────────────
artifact_write(
  object        = puf_classified,
  artifact_name = "puf_classified",
  file_path     = file.path(cfg$cache_dir, "puf_classified.rds"),
  phase         = phase_label,
  phase_script  = phase_script,
  cache_dir     = cfg$cache_dir,
  verbose       = cfg$verbose
)

message(glue::glue(
  "[{format(Sys.time(), '%Y-%m-%d %H:%M:%S')}] [02] Complete."
))
