# =============================================================================
# 00_run_all.R
#
# Master orchestration script for the midurethral sling pipeline.
# Source this single file to execute every step in order:
#
#   01  Build / cache merged multi-year PUF dataset
#   02  Classify provider specialties from Rndrng_Prvdr_Type
#   03  Run primary analysis (threshold = 10/yr)
#   03s Run primary analysis — _sens specialty grouping variants
#       (Pattern 1: LCDE2024_wildfires _sens suffix convention)
#   04  Run sensitivity analyses across threshold grid
#   05  Generate abstract text with programmatic statistics
#   06  Produce publication tables (Table 1, low-volume burden, time trends)
#   07  Produce publication figures (Figure 1 market share, Figure 2 volumes)
#   07b Produce the six manuscript figures (sling_figures_1_to_6.R)
#   08  Render the reproducible manuscript (output/manuscript.Rmd -> docx)
#
# Pattern from hollina/duke-replication (AER forthcoming) and
# mkiang/opioid_geographic (JAMA Network Open 2019).
#
# Usage:
#   Rscript 00_run_all.R          # run full pipeline from project root
#   source("00_run_all.R")        # from within RStudio
#
# Authors: Tyler Muffly, MD
# =============================================================================

# Bug fix B1: validate working directory before anything else.
# config::get() and source("R/…") use relative paths that only work from
# the project root. Running `Rscript path/to/00_run_all.R` from elsewhere
# fails with a confusing "file not found" rather than a diagnostic message.
if (!file.exists("config.yml")) {
  stop(paste0(
    "[00_run_all.R] config.yml not found in the current working directory.
",
    "  Current directory: ", getwd(), "
",
    "  Run this script from the project root:
",
    "    setwd('/path/to/project'); source('00_run_all.R')
",
    "  or: Rscript --vanilla 00_run_all.R  (from the project root)"
  ))
}

cfg <- config::get()
set.seed(cfg$seed)

# Pattern 4 (mkiang lab): here::here() for portable path management.
# here::i_am("config.yml") anchors the project root to the directory
# containing config.yml. After this call, here::here("data", "cache", "x.rds")
# resolves correctly regardless of working directory.
#
# Bug fix B5: here::i_am() was called but NO downstream script had been
# migrated to use here::here() yet, making it a dead dependency (requires
# the `here` package installed with no benefit). Kept as the anchor so
# scripts can adopt here::here() incrementally. Scripts still using
# file.path(cfg$cache_dir, ...) are correct and do not need migration;
# here::here() is most valuable for ad-hoc scripts outside 00_run_all.R.
here::i_am("config.yml")

# Load artifact manifest helpers — used for final reproducibility audit
source("R/artifact_manifest.R")

# ── Helpers ────────────────────────────────────────────────────────────────
log_step <- function(step_number, label) {
  # Bug fix B1: {'='<80} is Python string-multiplication syntax, not R.
  # glue evaluates '='<80 as the comparison "=" < 80, which coerces to
  # "=" < "80" by ASCII (61 < 56 = FALSE), printing "FALSE" as the banner.
  # strrep("=", 80) is the correct R idiom for repeating a character.
  separator <- strrep("=", 80)
  message(glue::glue(
    "\n{separator}\n",
    "[{format(Sys.time(), '%Y-%m-%d %H:%M:%S')}] ",
    "STEP {step_number}: {label}\n",
    "{separator}"
  ))
}

run_step <- function(step_number, label, script_path) {
  log_step(step_number, label)
  tryCatch(
    # Bug fix B2: local = FALSE runs each step in the global environment,
    # letting scripts silently overwrite each other's variables (cfg, n_raw,
    # puf_sling, etc.). Scripts communicate through filesystem caches, not
    # in-memory objects, so local = TRUE is the correct isolation boundary.
    source(script_path, local = TRUE),
    error = function(e) {
      message(glue::glue(
        "\n[FATAL] Step {step_number} ({label}) failed:\n  {conditionMessage(e)}\n",
        "Pipeline halted.  Fix the error and re-run."
      ))
      stop(e)
    }
  )
  invisible(NULL)
}

# ── Pipeline ───────────────────────────────────────────────────────────────
run_step(1,   "Build & cache merged PUF dataset",         "R/01_build_puf_cache.R")
run_step(2,   "Classify provider specialties",             "R/02_classify_specialties.R")
run_step(3,   "Primary analysis (concentration metrics)",   "R/03_run_primary_analysis.R")
run_step("3s","Primary analysis — _sens specialty schemes","R/03_run_primary_analysis_sens.R")
run_step(4,   "Sensitivity analyses (cross-sectional vs multi-year)","R/04_run_sensitivity_analyses.R")
run_step(5,   "Generate programmatic abstract",            "R/05_generate_abstract.R")
run_step(6,   "Produce publication tables",                "R/06_make_tables.R")
run_step(7,   "Produce publication figures",               "R/07_make_figures.R")
run_step("7b","Produce six manuscript figures (1-6)",       "R/07b_make_manuscript_figures.R")
run_step(8,   "Render reproducible manuscript (Rmd)",       "R/08_render_manuscript.R")

# ── Post-pipeline reproducibility audit ──────────────────────────────────
# Verify every artifact hash matches the manifest. If any file was
# modified outside the pipeline (manual edits, partial reruns on a
# different machine) this will fail loudly before the run is declared
# complete. This makes the 89-locality CMS audit trivial.
message("\nRunning post-pipeline artifact verification...")
manifest_verify(cfg$cache_dir, verbose = cfg$verbose)
manifest_summary(cfg$cache_dir, verbose = cfg$verbose)

separator <- strrep("=", 80)
message(glue::glue(
  "\n{separator}\n",
  "[{format(Sys.time(), '%Y-%m-%d %H:%M:%S')}] ALL STEPS COMPLETE\n",
  "{separator}\n"
))
