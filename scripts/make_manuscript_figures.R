# =============================================================================
# make_manuscript_figures.R
#
# Build the physician-year input from the pipeline cache and render the six
# publication figures (sling_figures_1_to_6.R) into output/figures/.
# Figure 5 (the state map) needs tigris to fetch Census geometry; if that is
# unavailable the other five figures are still produced.
#
# Usage: Rscript scripts/make_manuscript_figures.R [puf_classified.rds]
# =============================================================================

suppressWarnings(suppressMessages(library(dplyr)))
source("R/build_physician_year_tbl.R")
source("R/sling_figures_1_to_6.R")

args <- commandArgs(trailingOnly = TRUE)
puf_path <- if (length(args) >= 1) args[[1]] else
  "/Volumes/MufflySamsung 1/sling-volume-patterns/data/cache/puf_classified.rds"
save_dir <- "output/figures"

pyt <- build_physician_year_tbl(puf_path)
message(sprintf("[figures] physician-year rows: %d | columns: %s",
                nrow(pyt), paste(names(pyt), collapse = ", ")))

ok <- tryCatch({
  create_sling_figures_1_to_6(
    physician_year_tbl = pyt,
    save_dir = save_dir,
    excluded_years = 2017L,
    reference_volume = 50,
    map_year = NULL,
    geometry_year = 2023L
  )
  TRUE
}, error = function(e) {
  message("[figures] create_sling_figures_1_to_6 failed: ", conditionMessage(e))
  message("[figures] retrying figures 1-4 and 6 without the state map.")
  ts <- format(Sys.time(), "%Y%m%d_%H%M%S")
  prepared <- prepare_sling_figure_input(pyt, excluded_years = 2017L)
  flagged  <- add_observable_workforce_flags(prepared)
  figure_1_specialty_share(prepared, save_dir, ts)
  figure_2_workforce_and_volume(prepared, save_dir, ts)
  figure_3_volume_raincloud(prepared, save_dir, ts, reference_volume = 50)
  figure_4_lorenz_curves(prepared, save_dir, ts)
  figure_6_entrant_exit_balance(flagged, save_dir, ts)
  FALSE
})

message(if (ok) "[figures] all six figures rendered." else
        "[figures] five figures rendered (state map skipped).")
