# =============================================================================
# manuscript_sections.R
#
# Self-contained sections extracted from compute_manuscript_values() so each is
# individually readable and unit-testable (#5). Each takes explicit inputs and
# returns a slice of the value list (and any table), which the caller merges.
# The tightly-coupled distribution/concentration/model core stays in
# compute_manuscript_values() by design; splitting it would mean threading a
# dozen shared locals for little gain.
#
# Authors: Tyler Muffly, MD
# =============================================================================

#' Observable participation transitions (workforce) values + Table 5.
#'
#' @param pv provider-year table (Rndrng_NPI, specialty_group, annual_sling_count, year).
#' @param ac annual-concentration table with n_surgeons per specialty per year.
#' @param year_col name of the calendar-year column.
#' @return list(v = named scalars, t5 = data.frame for the supplement).
compute_workforce_values <- function(pv, ac, year_col) {
  `%>%` <- dplyr::`%>%`
  disp <- function(x) format(x, big.mark = ",")
  wfd <- build_workforce_dynamics(pv, year_col)      # once (was called twice)
  wf  <- wfd$annual
  ent_spec <- wfd$entrants_by_specialty %>%
    dplyr::group_by(specialty_group) %>%
    dplyr::summarise(n = sum(n_entrant), .groups = "drop")
  es <- function(grp) { x <- ent_spec$n[ent_spec$specialty_group == grp]; if (length(x) == 0) 0L else sum(x) }

  v <- list()
  v$ent_urps <- sum(ent_spec$n[grepl("^URPS", ent_spec$specialty_group)])  # both pathways
  v$ent_uro  <- es("Urology"); v$ent_gob <- es("General OB/GYN"); v$ent_migs <- es("MIGS")
  v$ent_min  <- min(wf$n_entrant, na.rm = TRUE); v$ent_max <- max(wf$n_entrant, na.rm = TRUE)
  v$entpct_min <- sprintf("%.1f", min(wf$pct_vol_entrant, na.rm = TRUE))
  v$entpct_max <- sprintf("%.1f", max(wf$pct_vol_entrant, na.rm = TRUE))
  v$cont_min <- min(wf$n_continuing, na.rm = TRUE); v$cont_max <- max(wf$n_continuing, na.rm = TRUE)
  v$exit_min <- min(wf$n_exiting, na.rm = TRUE); v$exit_max <- max(wf$n_exiting, na.rm = TRUE)
  v$ent_med  <- round(stats::median(wf$median_entrant_vol, na.rm = TRUE))
  v$ent_2020 <- wf$n_entrant[wf[[year_col]] == 2020]; v$entpct_2020 <- sprintf("%.1f", wf$pct_vol_entrant[wf[[year_col]] == 2020])
  v$ent_2022 <- wf$n_entrant[wf[[year_col]] == 2022]; v$entpct_2022 <- sprintf("%.1f", wf$pct_vol_entrant[wf[[year_col]] == 2022])
  urps_ac <- ac[ac$specialty_group == "URPS (OB/GYN)", ]
  v$urps_surg_2013 <- urps_ac$n_surgeons[which.min(urps_ac[[year_col]])]
  v$urps_surg_2023 <- urps_ac$n_surgeons[which.max(urps_ac[[year_col]])]

  nn  <- function(x) ifelse(is.na(x), "n/a", disp(x))
  pp5 <- function(x) ifelse(is.na(x), "n/a", sprintf("%.1f%%", x))
  t5 <- data.frame(
    Year = wf[[year_col]], Observable = disp(wf$n_observable),
    Entrants = nn(wf$n_entrant), Continuing = nn(wf$n_continuing), Exiting = nn(wf$n_exiting),
    `% volume by entrants` = pp5(wf$pct_vol_entrant),
    `Median entrant volume` = nn(round(wf$median_entrant_vol)),
    check.names = FALSE)
  list(v = v, t5 = t5)
}

#' Geography values: number of states and the list with no observable URPS.
#'
#' @param pv provider-year table. @param pc the classified PUF (for practice state).
#' @param year_col name of the calendar-year column.
#' @return list(v = named scalars).
compute_geography_values <- function(pv, pc, year_col) {
  `%>%` <- dplyr::`%>%`
  spec <- pv %>% dplyr::distinct(Rndrng_NPI, specialty_group)
  npi_state <- pc %>% dplyr::filter(HCPCS_Cd == "57288", .data[[year_col]] != 2017) %>%
    dplyr::transmute(Rndrng_NPI = as.character(Rndrng_NPI), state = Rndrng_Prvdr_State_Abrvtn) %>%
    dplyr::count(Rndrng_NPI, state) %>% dplyr::group_by(Rndrng_NPI) %>%
    dplyr::slice_max(n, n = 1, with_ties = FALSE) %>% dplyr::ungroup() %>% dplyr::select(Rndrng_NPI, state)
  geo <- spec %>% dplyr::left_join(npi_state, by = "Rndrng_NPI") %>% dplyr::filter(!is.na(state)) %>%
    dplyr::group_by(state) %>% dplyr::summarise(
      n = dplyr::n(), urps = sum(grepl("^URPS", specialty_group)),
      share = 100 * sum(grepl("^URPS", specialty_group)) / dplyr::n(), .groups = "drop")
  v <- list(n_states = nrow(geo))
  state_name <- c(AK = "Alaska", ND = "North Dakota", PR = "Puerto Rico", WY = "Wyoming",
                  HI = "Hawaii", MN = "Minnesota", DC = "the District of Columbia",
                  CT = "Connecticut", NE = "Nebraska")
  no_urps <- sort(geo$state[geo$urps == 0])
  full <- ifelse(no_urps %in% names(state_name), state_name[no_urps], no_urps)
  ns <- if (length(full) > 1) {
    paste0(paste(full[-length(full)], collapse = ", "), ", and ", full[length(full)])
  } else full
  v$no_urps_states <- sub("^the ", "The ", ns)   # sentence start
  v
}
