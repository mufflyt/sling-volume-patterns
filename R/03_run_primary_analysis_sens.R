# =============================================================================
# 03_run_primary_analysis_sens.R
#
# Sensitivity variant of Step 3 — tests whether primary conclusions hold under
# two alternative specialty aggregation schemes.
#
# Pattern from carlesmila/LCDE2024_wildfires: 6_HIA.R → 6_HIA_sens.R shares
# the step number but applies an alternative exposure-response assumption.
# Here the "assumption" being tested is the specialty grouping taxonomy.
#
# Sensitivity schemes:
#   A. Gynecologic  — FPMRS + OB/GYN merged into "Gynecologic specialists"
#                     vs Urology vs Other (tests whether FPMRS/OB-GYN split
#                     matters or if the gynecologic vs urologic contrast drives
#                     the result)
#   B. Binary       — "FPMRS only" vs "Non-FPMRS" (simplest possible split;
#                     directly answers "is this a subspecialist-concentration
#                     story?")
#
# Phase chain:
#   READS:  data/cache/puf_classified.rds        [Phase 2 artifact]
#   WRITES: data/cache/sens_a_gynecologic/specialty_summary.rds
#           data/cache/sens_b_binary/specialty_summary.rds
#           data/cache/sens_a_gynecologic/provider_volume.rds
#           data/cache/sens_b_binary/provider_volume.rds
#
# Authors: Tyler Muffly, MD
# =============================================================================

source("R/artifact_manifest.R")
source("R/analyze_sling_patterns.R")

cfg         <- config::get()
phase_label <- "03_primary_sens"
phase_script <- "R/03_run_primary_analysis_sens.R"

# ── Read Phase 2 artifact (same as primary analysis) ─────────────────────
input_artifact_path <- file.path(cfg$cache_dir, "puf_classified.rds")
puf_classified <- artifact_read(
  artifact_name = "puf_classified",
  file_path     = input_artifact_path,
  cache_dir     = cfg$cache_dir,
  verify_hash   = TRUE,
  verbose       = cfg$verbose
)

message(glue::glue(
  "[{format(Sys.time(), '%Y-%m-%d %H:%M:%S')}] ",
  "[03_sens] Loaded puf_classified: ",
  "{format(nrow(puf_classified), big.mark=',')} rows."
))

# =============================================================================
# HELPER: run one sensitivity scheme and write sub-artifacts
# =============================================================================

run_sens_scheme <- function(
    puf_classified_data,
    scheme_name,
    recode_fn,
    cfg_obj,
    phase,
    script
) {
  message(glue::glue(
    "[{format(Sys.time(), '%Y-%m-%d %H:%M:%S')}] ",
    "[03_sens] Running scheme: {scheme_name}"
  ))

  # Apply the alternative specialty grouping recode
  puf_recoded <- dplyr::mutate(
    puf_classified_data,
    specialty_group = recode_fn(specialty_group)
  )

  # Subdir for this scheme's artifacts
  scheme_cache <- file.path(cfg_obj$cache_dir, glue::glue("sens_{scheme_name}"))
  dir.create(scheme_cache, recursive = TRUE, showWarnings = FALSE)

  # Short-circuit if already run
  combined_path <- file.path(scheme_cache, "primary_analysis.rds")
  if (file.exists(combined_path)) {
    message(glue::glue(
      "  [{scheme_name}] Artifacts exist — skipping. ",
      "Delete {combined_path} to force recompute."
    ))
    return(invisible(NULL))
  }

  # Bug fix B1: cannot call analyze_midurethral_sling_patterns() here because
  # Step 2 of that function unconditionally overwrites specialty_group via
  # classify_provider_specialty(Rndrng_Prvdr_Type), discarding the recode.
  # Fix: call the pipeline helpers directly, starting from aggregation
  # (skipping the classification step entirely — recode already applied).
  # puf_recoded is already filtered to CPT 57288 from 01_build_puf_cache.R.
  provider_volume_sens <- aggregate_to_provider_level(
    puf_recoded,
    year_col = cfg_obj$year_col_name,
    verbose  = FALSE
  )

  results <- list(
    provider_volume       = provider_volume_sens,
    specialty_summary     = build_specialty_summary(
      provider_volume_sens,
      concentration_cutoffs = cfg_obj$concentration_cutoffs,
      verbose = FALSE
    ),
    concentration_metrics = build_concentration_metrics(
      provider_volume_sens,
      concentration_cutoffs = cfg_obj$concentration_cutoffs,
      verbose = FALSE
    ),
    time_trends = if (!is.null(cfg_obj$year_col_name) &&
                       cfg_obj$year_col_name %in% names(puf_recoded)) {
      build_time_trends(provider_volume_sens,
                        year_col = cfg_obj$year_col_name,
                        verbose  = FALSE)
    } else {
      NULL
    }
  )

  artifact_write(
    object        = results$specialty_summary,
    artifact_name = glue::glue("sens_{scheme_name}_specialty_summary"),
    file_path     = file.path(scheme_cache, "specialty_summary.rds"),
    phase         = phase,
    phase_script  = script,
    cache_dir     = cfg_obj$cache_dir,
    verbose       = cfg_obj$verbose
  )

  artifact_write(
    object        = results$provider_volume,
    artifact_name = glue::glue("sens_{scheme_name}_provider_volume"),
    file_path     = file.path(scheme_cache, "provider_volume.rds"),
    phase         = phase,
    phase_script  = script,
    cache_dir     = cfg_obj$cache_dir,
    verbose       = cfg_obj$verbose
  )

  artifact_write(
    object        = results,
    artifact_name = glue::glue("sens_{scheme_name}_primary_analysis"),
    file_path     = combined_path,
    phase         = phase,
    phase_script  = script,
    cache_dir     = cfg_obj$cache_dir,
    verbose       = cfg_obj$verbose
  )

  message(glue::glue(
    "  [{scheme_name}] Done. ",
    "{nrow(results$specialty_summary)} specialty groups, ",
    "{nrow(results$provider_volume)} provider rows."
  ))
  invisible(results)
}

# =============================================================================
# SCHEME A: Gynecologic specialists (FPMRS + OB/GYN merged)
# =============================================================================
# Tests whether the conclusion "FPMRS outperforms OB/GYN" survives when
# the two gynecologic groups are collapsed.  If Gynecologic > Urology still
# holds, the result is robust to the FPMRS/OB-GYN split.

recode_gynecologic <- function(specialty_group_vector) {
  dplyr::case_when(
    specialty_group_vector %in% c("FPMRS", "OB/GYN") ~ "Gynecologic specialists",
    specialty_group_vector == "Urology"               ~ "Urology",
    TRUE                                              ~ "Other"
  )
}

run_sens_scheme(
  puf_classified_data = puf_classified,
  scheme_name         = "a_gynecologic",
  recode_fn           = recode_gynecologic,
  cfg_obj             = cfg,
  phase               = phase_label,
  script              = phase_script
)

# =============================================================================
# SCHEME B: Binary split — FPMRS vs Non-FPMRS
# =============================================================================
# The simplest possible question: does subspecialty training predict volume?
# Collapses OB/GYN, Urology, and Other into a single "Non-FPMRS" category.

recode_binary <- function(specialty_group_vector) {
  dplyr::case_when(
    specialty_group_vector == "FPMRS" ~ "FPMRS",
    TRUE                              ~ "Non-FPMRS"
  )
}

run_sens_scheme(
  puf_classified_data = puf_classified,
  scheme_name         = "b_binary",
  recode_fn           = recode_binary,
  cfg_obj             = cfg,
  phase               = phase_label,
  script              = phase_script
)

# =============================================================================
# Inline comparison of schemes vs primary
# =============================================================================

primary_summary_path <- file.path(cfg$cache_dir, "specialty_summary.rds")
sens_a_summary_path  <- file.path(cfg$cache_dir, "sens_a_gynecologic",
                                  "specialty_summary.rds")
sens_b_summary_path  <- file.path(cfg$cache_dir, "sens_b_binary",
                                  "specialty_summary.rds")

# Bug fix B2: guard ALL three files before reading. The primary artifact
# may exist but the sens artifacts may not (e.g. partial run). An unguarded
# readRDS() on a missing file stops with an unintelligible error.
if (file.exists(primary_summary_path) &&
    file.exists(sens_a_summary_path)  &&
    file.exists(sens_b_summary_path)) {
  primary_ss <- readRDS(primary_summary_path)
  sens_a_ss  <- readRDS(sens_a_summary_path)
  sens_b_ss  <- readRDS(sens_b_summary_path)

  message(glue::glue(
    "\n[03_sens] Specialty summary comparison:\n",
    "  Primary (4 groups):\n"
  ))
  print(primary_ss[, c("specialty_group", "n_providers",
                        "gini_coefficient", "pct_of_all_slings")])

  message("  Scheme A (gynecologic merged):")
  print(sens_a_ss[, c("specialty_group", "n_providers",
                       "gini_coefficient", "pct_of_all_slings")])

  message("  Scheme B (binary FPMRS / Non-FPMRS):")
  print(sens_b_ss[, c("specialty_group", "n_providers",
                       "gini_coefficient", "pct_of_all_slings")])
}

message(glue::glue(
  "[{format(Sys.time(), '%Y-%m-%d %H:%M:%S')}] [03_sens] Complete."
))
