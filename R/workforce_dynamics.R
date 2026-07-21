# =============================================================================
# workforce_dynamics.R
#
# Annual workforce entry/continuation/exit for the observable sling surgeon
# pool, using a two-year washout to separate genuine adoption from year-to-year
# fluctuation (following recent surgical-workforce comparators).
#
# Because CMS suppresses providers with <11 beneficiaries, everyone in the data
# already performs >= 11 slings/year; these are therefore *newly observable*
# surgeons, not definitively new sling surgeons.
#
# Definitions (per calendar year Y, over the observable years present in the
# data; the 2017 gap is handled by using the nearest available prior/next years):
#   observable   surgeon billing >= 11 slings in year Y
#   entrant      observable in Y, absent in BOTH of the two prior available
#                years (needs two prior years to exist)
#   continuing   observable in Y and present in at least one prior available
#                year (i.e., observable but not an entrant)
#   exiting      observable in Y, absent in BOTH of the two subsequent available
#                years (needs two subsequent years to exist)
#
# Authors: Tyler Muffly, MD
# =============================================================================

#' @noRd
#' Build the annual workforce-dynamics table.
#' @return one row per calendar year with counts and entrant volume share,
#'   plus a `entrants_by_specialty` long tibble.
build_workforce_dynamics <- function(provider_volume_data, year_col,
                                     washout = 2L) {
  stopifnot(all(c("Rndrng_NPI", "specialty_group", "annual_sling_count", year_col)
                %in% names(provider_volume_data)))
  years <- sort(unique(provider_volume_data[[year_col]]))
  npis_by_year <- lapply(years, function(y)
    unique(provider_volume_data$Rndrng_NPI[provider_volume_data[[year_col]] == y]))
  names(npis_by_year) <- as.character(years)

  rows <- lapply(seq_along(years), function(i) {
    y      <- years[i]
    in_y   <- npis_by_year[[i]]
    prior  <- if (i > washout) unlist(npis_by_year[(i - washout):(i - 1)]) else NULL
    nxt    <- if (i <= length(years) - washout) unlist(npis_by_year[(i + 1):(i + washout)]) else NULL
    has_prior <- i > washout
    has_next  <- i <= length(years) - washout

    entrant <- if (has_prior) setdiff(in_y, prior) else character(0)
    exiting <- if (has_next)  setdiff(in_y, nxt)   else character(0)

    yr_dat  <- provider_volume_data[provider_volume_data[[year_col]] == y, ]
    tot_vol <- sum(yr_dat$annual_sling_count, na.rm = TRUE)
    ent_vol <- sum(yr_dat$annual_sling_count[yr_dat$Rndrng_NPI %in% entrant], na.rm = TRUE)

    tibble::tibble(
      !!year_col        := y,
      n_observable      = length(in_y),
      n_entrant         = if (has_prior) length(entrant) else NA_integer_,
      n_continuing      = if (has_prior) length(in_y) - length(entrant) else NA_integer_,
      n_exiting         = if (has_next)  length(exiting) else NA_integer_,
      pct_vol_entrant   = if (has_prior && tot_vol > 0) 100 * ent_vol / tot_vol else NA_real_,
      median_entrant_vol = if (has_prior && length(entrant) > 0)
        stats::median(yr_dat$annual_sling_count[yr_dat$Rndrng_NPI %in% entrant]) else NA_real_
    )
  })
  annual <- dplyr::bind_rows(rows)

  # Entrants by specialty (present in Y, absent both prior available years)
  ent_spec <- lapply(seq_along(years), function(i) {
    if (i <= washout) return(NULL)
    y     <- years[i]
    prior <- unlist(npis_by_year[(i - washout):(i - 1)])
    yr_dat <- provider_volume_data[provider_volume_data[[year_col]] == y, ]
    yr_dat <- yr_dat[!yr_dat$Rndrng_NPI %in% prior, ]
    if (nrow(yr_dat) == 0) return(NULL)
    dplyr::count(yr_dat, specialty_group, name = "n_entrant") |>
      dplyr::mutate(!!year_col := y)
  })
  entrants_by_specialty <- dplyr::bind_rows(ent_spec) |>
    dplyr::relocate(dplyr::all_of(year_col))

  list(annual = annual, entrants_by_specialty = entrants_by_specialty)
}
