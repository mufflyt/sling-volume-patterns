# =============================================================================
# classification_schemes.R
#
# Specialty-classification sensitivity. The primary analysis assigns each
# physician-YEAR a specialty (CMS provider type that year, plus fixed ABOG/ABU
# subspecialty membership), i.e. it is already time-varying at the CMS level.
# Because the manuscript's headline concerns CHANGES in specialty market share,
# we compare three assignment schemes:
#
#   time_varying     one specialty per physician-year (primary; as time-varying
#                    as the data allow — see limitation below)
#   modal            one specialty per physician for all years = the group they
#                    appear in for the most years (ties broken by total volume);
#                    this is the "single most-frequent specialty" the manuscript
#                    text describes
#   ever_urps_migs   one specialty per physician: URPS if ever URPS in any year,
#                    else MIGS if ever MIGS, else their modal specialty
#
# LIMITATION: the ABOG registry supplies no certification DATE, so ABOG URPS/MIGS
# membership cannot be switched on at a physician's certification year; it is
# treated as fixed across the study period in every scheme. Only the CMS provider
# type varies year to year. True per-year subspecialty gating would require ABOG
# (and ABU) certification years.
#
# Authors: Tyler Muffly, MD
# =============================================================================

#' @noRd
#' Modal specialty per NPI: the specialty_group present in the most years,
#' ties broken by greatest total volume, then alphabetically for determinism.
.modal_specialty_by_npi <- function(provider_volume_data) {
  provider_volume_data |>
    dplyr::group_by(Rndrng_NPI, specialty_group) |>
    dplyr::summarise(
      .n_years = dplyr::n(),
      .vol     = sum(annual_sling_count, na.rm = TRUE),
      .groups  = "drop"
    ) |>
    dplyr::group_by(Rndrng_NPI) |>
    dplyr::arrange(dplyr::desc(.n_years), dplyr::desc(.vol), specialty_group,
                   .by_group = TRUE) |>
    dplyr::slice(1) |>
    dplyr::ungroup() |>
    dplyr::select(Rndrng_NPI, .modal = specialty_group)
}

#' @noRd
#' Reassign specialty_group in a provider-volume table under a chosen scheme.
#' Returns the same table with specialty_group replaced (time_varying returns it
#' unchanged). Row count and every other column are preserved.
assign_specialty_scheme <- function(
    provider_volume_data,
    scheme = c("time_varying", "modal", "ever_urps_migs")
) {
  scheme <- match.arg(scheme)
  stopifnot(all(
    c("Rndrng_NPI", "specialty_group", "annual_sling_count") %in%
      names(provider_volume_data)
  ))
  if (scheme == "time_varying") {
    return(provider_volume_data)
  }

  modal <- .modal_specialty_by_npi(provider_volume_data)

  if (scheme == "modal") {
    return(
      provider_volume_data |>
        dplyr::left_join(modal, by = "Rndrng_NPI") |>
        dplyr::mutate(specialty_group = .modal) |>
        dplyr::select(-.modal)
    )
  }

  # ever_urps_migs: URPS if ever URPS, else MIGS if ever MIGS, else modal.
  ever <- provider_volume_data |>
    dplyr::group_by(Rndrng_NPI) |>
    dplyr::summarise(
      .ever_urps = any(specialty_group == "URPS"),
      .ever_migs = any(specialty_group == "MIGS"),
      .groups = "drop"
    )
  provider_volume_data |>
    dplyr::left_join(modal, by = "Rndrng_NPI") |>
    dplyr::left_join(ever, by = "Rndrng_NPI") |>
    dplyr::mutate(
      specialty_group = dplyr::case_when(
        .ever_urps ~ "URPS",
        .ever_migs ~ "MIGS",
        TRUE       ~ .modal
      )
    ) |>
    dplyr::select(-.modal, -.ever_urps, -.ever_migs)
}

#' @noRd
#' Per-scheme summary: specialty distribution (providers, procedures, share)
#' plus the URPS and gynecologic (URPS+MIGS+General OB/GYN) market-share trends
#' (OLS slope in percentage points per year, with p-value). One tibble per call;
#' bind across schemes to build the sensitivity table.
summarise_scheme <- function(provider_volume_scheme, year_col, scheme_label) {
  total <- sum(provider_volume_scheme$annual_sling_count, na.rm = TRUE)
  dist <- provider_volume_scheme |>
    dplyr::group_by(specialty_group) |>
    dplyr::summarise(
      scheme       = scheme_label,
      n_providers  = dplyr::n_distinct(Rndrng_NPI),
      procedures   = sum(annual_sling_count, na.rm = TRUE),
      pct_of_all   = 100 * sum(annual_sling_count, na.rm = TRUE) / total,
      .groups = "drop"
    ) |>
    dplyr::relocate(scheme)

  # Market-share trends per year
  per_year <- provider_volume_scheme |>
    dplyr::group_by(dplyr::across(dplyr::all_of(year_col))) |>
    dplyr::summarise(
      tot      = sum(annual_sling_count, na.rm = TRUE),
      urps     = 100 * sum(annual_sling_count[specialty_group == "URPS"], na.rm = TRUE) / tot,
      gyn      = 100 * sum(annual_sling_count[specialty_group %in%
                     c("URPS", "MIGS", "General OB/GYN")], na.rm = TRUE) / tot,
      .groups = "drop"
    )
  trend <- function(y) {
    m <- stats::lm(y ~ per_year[[year_col]]); s <- summary(m)
    c(slope = unname(stats::coef(m)[2]), p = s$coefficients[2, 4])
  }
  urps_t <- trend(per_year$urps); gyn_t <- trend(per_year$gyn)

  list(
    distribution = dist,
    trends = tibble::tibble(
      scheme            = scheme_label,
      urps_slope_pp_yr  = round(urps_t["slope"], 3),
      urps_p            = urps_t["p"],
      gyn_slope_pp_yr   = round(gyn_t["slope"], 3),
      gyn_p             = gyn_t["p"]
    )
  )
}
