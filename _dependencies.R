# =============================================================================
# _dependencies.R  —  renv dependency anchor.  DO NOT DELETE.
#
# renv discovers project dependencies by a STATIC scan of the R source; it does
# not execute this file. Listing the statistical/modeling packages here
# guarantees they are retained in renv.lock by `renv::snapshot()` even if a
# future edit removes an inline `pkg::fun` reference from the analysis code.
#
# These back the repeated-measures models and reporting (R/volume_models.R,
# R/reporting_stats_helpers.R). glmmTMB additionally needs an OpenMP-linked TMB
# at runtime (on macOS: `brew install libomp`); it is still recorded here so
# environments that can load it restore the exact version. The GEE path
# (geepack) has no such requirement.
#
# The `if (FALSE)` guard means nothing is loaded if this file is ever sourced,
# while renv's static scanner still detects every reference below.
# =============================================================================

if (FALSE) {
  library(geepack)      # Poisson GEE clustered by NPI (fit_volume_gee)
  library(glmmTMB)      # negative-binomial mixed model (fit_volume_nb_mixed)
  library(broom.mixed)  # tidy() output for glmmTMB fixed effects
  library(ggdist)       # raincloud (stat_halfeye) in sling_figures_1_to_6
  library(patchwork)    # multi-panel figure assembly
  library(sf)           # spatial geometry for the state map (Figure 5)
  library(tigris)       # Census state boundaries for the state map
}
