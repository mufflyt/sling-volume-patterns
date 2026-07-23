# =============================================================================
# specialty_groups.R
#
# Central specialty-group taxonomy: the single source of truth for group codes
# (the internal specialty_group values), display labels, ordering, and
# predicates. Changing a label, reordering the groups, or adding/removing a
# group is a one-line edit here instead of hunting ~150 string literals across
# analyze_sling_patterns.R and compute_manuscript_values.R.
#
# `code` matches the specialty_group value produced by
# analyze_midurethral_sling_patterns(split_urps_pathway = TRUE).
#
# Flags:
#   is_urps        - either URPS certification pathway
#   well_populated - large enough for concentration / model displays (Table 2)
#   inferential    - included in the volume model contrasts (Table 3)
#
# Authors: Tyler Muffly, MD
# =============================================================================

#' The specialty-group taxonomy as a tibble (source of truth).
#' @noRd
specialty_group_taxonomy <- function() {
  tibble::tribble(
    ~code,             ~display,                 ~order, ~is_urps, ~well_populated, ~inferential,
    "URPS (OB/GYN)",   "URPS, OB/GYN pathway",   1L,     TRUE,     TRUE,            TRUE,
    "URPS (urology)",  "URPS, urology pathway",  2L,     TRUE,     TRUE,            TRUE,
    "Urology",         "Urology (non-URPS)",     3L,     FALSE,    TRUE,            TRUE,
    "General OB/GYN",  "Other non-URPS OB/GYN",  4L,     FALSE,    TRUE,            TRUE,
    "Other/uncertain", "Other/uncertain",        5L,     FALSE,    FALSE,           FALSE,
    "MIGS",            "MIGS",                   6L,     FALSE,    FALSE,           TRUE
  )
}

#' Ordered group codes, optionally filtered by a flag.
#' @param which one of "all", "distribution" (all real groups for Table 1),
#'   "concentration" (well_populated), or "inferential" (model contrasts).
#' @noRd
sg_codes <- function(which = c("all", "distribution", "concentration", "inferential")) {
  which <- match.arg(which)
  tx <- specialty_group_taxonomy()[order(specialty_group_taxonomy()$order), ]
  tx <- switch(which,
    all           = tx,
    distribution  = tx,                       # every real group, in order
    concentration = tx[tx$well_populated, ],
    inferential   = tx[tx$inferential, ])
  tx$code
}

#' Display labels for a vector of group codes (falls back to the code).
#' @noRd
sg_display <- function(codes) {
  tx <- specialty_group_taxonomy()
  out <- tx$display[match(codes, tx$code)]
  ifelse(is.na(out), codes, out)
}

#' TRUE for any URPS pathway (or the combined "URPS" label).
#' @noRd
sg_is_urps <- function(x) grepl("^URPS", x)
