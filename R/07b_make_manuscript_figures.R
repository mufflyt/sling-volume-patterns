# =============================================================================
# 07b_make_manuscript_figures.R
#
# Step 7b: render the six publication figures (sling_figures_1_to_6.R) that
# accompany the manuscript, alongside the classic figures from step 07.
# Builds the physician-year input from the frozen Phase 2 cache via the same
# classification logic as the manuscript, then writes timestamped PNGs to
# output/figures/.
#
# READS:  data/cache/puf_classified.rds   [Phase 2 artifact]
# WRITES: output/figures/figure_1..6_*_<timestamp>.png
#
# Optional heavy dependencies (ggdist, patchwork, sf, tigris); skips gracefully
# if they are unavailable, and the state map (Figure 5) is non-fatal if tigris
# cannot fetch Census geometry.
#
# Authors: Tyler Muffly, MD
# =============================================================================

cfg      <- config::get()
puf_path <- file.path(cfg$cache_dir, "puf_classified.rds")
save_dir <- cfg$figures_dir

fig_pkgs <- c("ggdist", "patchwork", "sf", "tigris", "ggplot2", "tidyr", "stringr")
missing  <- fig_pkgs[!vapply(fig_pkgs, requireNamespace, logical(1), quietly = TRUE)]

if (length(missing) > 0L) {
  message(glue::glue(
    "[07b_make_manuscript_figures] missing packages ({paste(missing, collapse=', ')}) ",
    "-- skipping the six-figure set."
  ))
} else if (!file.exists(puf_path)) {
  message(glue::glue(
    "[07b_make_manuscript_figures] {puf_path} not found -- run steps 01-02 first. Skipping."
  ))
} else {
  source("R/build_physician_year_tbl.R")
  source("R/sling_figures_1_to_6.R")

  pyt <- build_physician_year_tbl(puf_path)
  message(glue::glue(
    "[07b_make_manuscript_figures] physician-year rows: {nrow(pyt)}"
  ))

  tryCatch(
    create_sling_figures_1_to_6(
      physician_year_tbl = pyt,
      save_dir           = save_dir,
      excluded_years     = as.integer(unlist(cfg$exclude_years)),
      reference_volume   = 50,
      map_year           = NULL,
      geometry_year      = cfg$study_end_year
    ),
    error = function(e) {
      # The state map is the usual failure point (offline tigris). Render the
      # other five so a network hiccup does not lose the whole figure set.
      message("[07b_make_manuscript_figures] full set failed (", conditionMessage(e),
              "); rendering figures 1-4 and 6 without the state map.")
      ts       <- format(Sys.time(), "%Y%m%d_%H%M%S")
      prepared <- prepare_sling_figure_input(pyt, excluded_years = as.integer(unlist(cfg$exclude_years)))
      flagged  <- add_observable_workforce_flags(prepared)
      figure_1_specialty_share(prepared, save_dir, ts)
      figure_2_workforce_and_volume(prepared, save_dir, ts)
      figure_3_volume_raincloud(prepared, save_dir, ts, reference_volume = 50)
      figure_4_lorenz_curves(prepared, save_dir, ts)
      figure_6_entrant_exit_balance(flagged, save_dir, ts)
    }
  )

  message(glue::glue(
    "[{format(Sys.time(), '%Y-%m-%d %H:%M:%S')}] ",
    "[07b_make_manuscript_figures] Manuscript figures written to {save_dir}."
  ))
}
