# =============================================================================
# build_physician_year_tbl.R
#
# Assemble the one-row-per-physician-year input that sling_figures_1_to_6.R
# expects, drawn from the same pipeline cache and classification logic as the
# manuscript so the figures cannot drift from the text. Columns:
#   npi, year, procedures, specialty_fixed, specialty_cert_gated, state_abbr
#
# All calendar years are returned (including 2017); the figure functions apply
# their own `excluded_years` filter. specialty_fixed is the combined-URPS
# (eventual) membership; specialty_cert_gated is the time-varying, ABOG
# certification-gated membership with urology-pathway URPS folded in.
#
# Authors: Tyler Muffly, MD
# =============================================================================

build_physician_year_tbl <- function(
    puf_classified_path,
    abog_csv     = "data/canonical_abog/canonical_abog_npi_LATEST.csv",
    abu_csv      = "data/abu_urology/abu_urps_npi_LATEST.csv",
    certyear_csv = "data/canonical_abog/abog_subspecialty_certyear_LATEST.csv",
    year_col     = "puf_year",
    r_dir        = "R"
) {
  `%>%` <- dplyr::`%>%`
  source(file.path(r_dir, "reporting_stats_helpers.R"), local = TRUE)
  source(file.path(r_dir, "analyze_sling_patterns.R"),  local = TRUE)
  source(file.path(r_dir, "classification_schemes.R"),  local = TRUE)

  pc  <- readRDS(puf_classified_path)
  abu <- readr::read_csv(abu_csv, show_col_types = FALSE)$npi

  # Fixed (combined-URPS) membership, all years.
  pv_fixed <- analyze_midurethral_sling_patterns(
    pc, year_col = year_col, abog_npi_csv = abog_csv,
    urps_urology_npi_csv = abu_csv, verbose = FALSE
  )$provider_volume %>%
    dplyr::transmute(
      npi = as.character(Rndrng_NPI),
      year = .data[[year_col]],
      procedures = annual_sling_count,
      specialty_fixed = specialty_group
    )

  # Time-varying, certification-gated membership, all years. Start from the
  # CMS-only classification (no ABOG/ABU split), gate URPS/MIGS on the ABOG
  # subspecialty certification year, then fold in urology-pathway URPS (fixed).
  base <- analyze_midurethral_sling_patterns(
    pc, year_col = year_col, abog_npi_csv = NULL,
    urps_urology_npi_csv = NULL, verbose = FALSE
  )$provider_volume %>%
    dplyr::mutate(specialty_group = ifelse(
      specialty_group == "OB/GYN", "General OB/GYN", specialty_group))
  cw <- readr::read_csv(certyear_csv, show_col_types = FALSE) %>%
    dplyr::mutate(npi = as.character(npi))
  pv_cert <- assign_time_varying_certgated(base, year_col, cw) %>%
    dplyr::mutate(specialty_group = ifelse(
      Rndrng_NPI %in% abu & specialty_group != "MIGS", "URPS", specialty_group)) %>%
    dplyr::transmute(
      npi = as.character(Rndrng_NPI),
      year = .data[[year_col]],
      specialty_cert_gated = specialty_group
    )

  # Practice state per physician-year (modal state within the year).
  npi_year_state <- pc %>%
    dplyr::filter(HCPCS_Cd == "57288") %>%
    dplyr::transmute(
      npi = as.character(Rndrng_NPI), year = .data[[year_col]],
      state_abbr = Rndrng_Prvdr_State_Abrvtn) %>%
    dplyr::count(npi, year, state_abbr) %>%
    dplyr::group_by(npi, year) %>%
    dplyr::slice_max(n, n = 1, with_ties = FALSE) %>%
    dplyr::ungroup() %>%
    dplyr::select(npi, year, state_abbr)

  # analyze() with the ABOG list reassigns non-ABOG "Other" providers to
  # Urology (kept), but the no-ABOG base used for certification gating drops
  # them, so those NPI-years have no cert-gated match. They are all non-URPS
  # urology in both schemes, so fall back to the fixed group for them.
  pv_fixed %>%
    dplyr::left_join(pv_cert, by = c("npi", "year")) %>%
    dplyr::mutate(specialty_cert_gated =
                    dplyr::coalesce(specialty_cert_gated, specialty_fixed)) %>%
    dplyr::left_join(npi_year_state, by = c("npi", "year")) %>%
    tibble::as_tibble()
}
