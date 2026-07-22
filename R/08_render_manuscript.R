# =============================================================================
# 08_render_manuscript.R
#
# Step 8: render the reproducible manuscript. output/manuscript.Rmd computes
# every number inline from the frozen puf_classified cache (Phase 2 artifact)
# via compute_manuscript_values(), so the prose and the analysis cannot drift.
#
# READS:  data/cache/puf_classified.rds   [Phase 2 artifact]
#         output/manuscript.Rmd
# WRITES: output/manuscript.docx
#
# Skips gracefully if rmarkdown/pandoc are unavailable.
#
# Authors: Tyler Muffly, MD
# =============================================================================

cfg <- config::get()

rmd_path  <- "output/manuscript.Rmd"
puf_path  <- file.path(cfg$cache_dir, "puf_classified.rds")

if (!requireNamespace("rmarkdown", quietly = TRUE) ||
    !rmarkdown::pandoc_available()) {
  message("[08_render_manuscript] rmarkdown/pandoc unavailable -- skipping manuscript render.")
} else if (!file.exists(puf_path)) {
  message(glue::glue(
    "[08_render_manuscript] {puf_path} not found -- run steps 01-02 first. Skipping."
  ))
} else {
  # The Rmd reads root-relative paths (R/, data/, config); knit from the project
  # root. compute_manuscript_values() defaults to the config cache, and the
  # PUF_CLASSIFIED env var can override it for ad-hoc renders.
  rmarkdown::render(
    rmd_path,
    output_file   = "manuscript.docx",
    knit_root_dir = getwd(),
    quiet         = TRUE
  )
  message(glue::glue(
    "[{format(Sys.time(), '%Y-%m-%d %H:%M:%S')}] ",
    "[08_render_manuscript] Rendered output/manuscript.docx from manuscript.Rmd."
  ))
}
