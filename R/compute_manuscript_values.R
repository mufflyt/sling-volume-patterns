# =============================================================================
# compute_manuscript_values.R
#
# Single source of truth for every number in the manuscript. Reads the frozen
# puf_classified cache, re-runs the analysis, models, workforce, geography, and
# classification-bound computations, and returns one named list. The manuscript
# (output/manuscript.Rmd) references these values inline, so the prose and the
# analysis can never drift apart.
#
# Returns a list with:
#   $v    named scalars/strings (e.g. v$urps_pct, v$gee_urology)
#   $tab  data frames ready for kable (tab$t1 ... tab$t5)
#
# Authors: Tyler Muffly, MD
# =============================================================================

suppressWarnings(suppressMessages({
  requireNamespace("dplyr", quietly = TRUE)
}))

compute_manuscript_values <- function(
    puf_classified_path,
    abog_csv     = "data/canonical_abog/canonical_abog_npi_LATEST.csv",
    abu_csv      = "data/abu_urology/abu_urps_npi_LATEST.csv",
    certyear_csv = "data/canonical_abog/abog_subspecialty_certyear_LATEST.csv",
    exclude_years = 2017L,
    year_col      = "puf_year",
    r_dir         = "R"
) {
  `%>%` <- dplyr::`%>%`
  source(file.path(r_dir, "reporting_stats_helpers.R"), local = TRUE)
  source(file.path(r_dir, "analyze_sling_patterns.R"),  local = TRUE)
  source(file.path(r_dir, "classification_schemes.R"),  local = TRUE)
  source(file.path(r_dir, "workforce_dynamics.R"),      local = TRUE)
  source(file.path(r_dir, "volume_models.R"),           local = TRUE)

  pc <- readRDS(puf_classified_path)

  # ── Analyses: full (all years) and analytic (2017 excluded) ────────────────
  res_full <- analyze_midurethral_sling_patterns(
    pc, year_col = year_col, abog_npi_csv = abog_csv,
    urps_urology_npi_csv = abu_csv, verbose = FALSE
  )
  res <- analyze_midurethral_sling_patterns(
    pc, year_col = year_col, abog_npi_csv = abog_csv,
    urps_urology_npi_csv = abu_csv, exclude_years = exclude_years, verbose = FALSE
  )
  pv   <- res$provider_volume
  pvf  <- res_full$provider_volume
  tt   <- res$time_trends
  cm   <- res$concentration_metrics
  ac   <- res$annual_concentration

  fmt_p  <- function(p) ifelse(is.na(p), "n/a", ifelse(p < 0.001, "<0.001", sprintf("%.3f", p)))
  rr_ci  <- function(row) sprintf("%.2f (%.2f–%.2f)", row$rate_ratio, row$ci_low, row$ci_high)
  yr_val <- function(df, y, col) df[[col]][df[[year_col]] == y]

  v <- list()

  # ── Cohort and annual volume ───────────────────────────────────────────────
  v$full_physicians <- dplyr::n_distinct(pvf$Rndrng_NPI)
  v$full_services   <- sum(pvf$annual_sling_count)
  v$full_pyears     <- nrow(pvf)
  ny <- pvf %>% dplyr::count(Rndrng_NPI, name = "ny")
  v$persist_1    <- sum(ny$ny == 1)
  v$persist_2_5  <- sum(ny$ny %in% 2:5)
  v$persist_6_10 <- sum(ny$ny %in% 6:10)
  v$persist_11   <- sum(ny$ny == 11)
  v$persist_1_pct    <- round(100 * v$persist_1 / v$full_physicians)
  v$persist_2_5_pct  <- round(100 * v$persist_2_5 / v$full_physicians)
  v$persist_6_10_pct <- round(100 * v$persist_6_10 / v$full_physicians)
  v$persist_11_pct   <- round(100 * v$persist_11 / v$full_physicians)

  v$analytic_physicians <- dplyr::n_distinct(pv$Rndrng_NPI)
  v$analytic_procs      <- sum(pv$annual_sling_count)
  v$analytic_pyears     <- nrow(pv)

  yr <- pv %>% dplyr::group_by(.data[[year_col]]) %>%
    dplyr::summarise(procs = sum(annual_sling_count),
                     surg  = dplyr::n_distinct(Rndrng_NPI), .groups = "drop")
  v$procs_2013 <- yr_val(yr, 2013, "procs"); v$procs_2023 <- yr_val(yr, 2023, "procs")
  v$surg_2013  <- yr_val(yr, 2013, "surg");  v$surg_2023  <- yr_val(yr, 2023, "surg")
  v$procs_2020 <- yr_val(yr, 2020, "procs"); v$procs_2022 <- yr_val(yr, 2022, "procs")
  m <- stats::lm(procs ~ yr[[year_col]], yr)
  v$proc_slope <- round(stats::coef(m)[2]); v$proc_slope_p <- fmt_p(summary(m)$coefficients[2, 4])

  # ── Specialty distribution + per-specialty share trends (Table 1) ──────────
  order_grp <- c("URPS", "Urology", "General OB/GYN", "MIGS")
  dist <- pv %>% dplyr::group_by(specialty_group) %>%
    dplyr::summarise(
      phys  = dplyr::n_distinct(Rndrng_NPI), pyears = dplyr::n(),
      procs = sum(annual_sling_count),
      med = stats::median(annual_sling_count),
      p25 = stats::quantile(annual_sling_count, .25, names = FALSE),
      p75 = stats::quantile(annual_sling_count, .75, names = FALSE),
      .groups = "drop") %>%
    dplyr::mutate(pct = 100 * procs / sum(procs))
  shr <- tt %>% dplyr::group_by(specialty_group) %>%
    dplyr::group_modify(~{
      mm <- stats::lm(pct_slings_this_year ~ .x[[year_col]], .x); ci <- stats::confint(mm)[2, ]
      dplyr::tibble(
        s2013 = .x$pct_slings_this_year[which.min(.x[[year_col]])],
        s2023 = .x$pct_slings_this_year[which.max(.x[[year_col]])],
        slope = stats::coef(mm)[2], lo = ci[1], hi = ci[2],
        p = summary(mm)$coefficients[2, 4])
    }) %>% dplyr::ungroup()
  d <- dplyr::left_join(dist, shr, by = "specialty_group")
  d <- d[match(order_grp, d$specialty_group), ]

  disp <- function(x) format(x, big.mark = ",")
  t1 <- data.frame(
    Specialty = c("URPS", "Urology (non-URPS)", "General OB/GYN", "MIGS", "**Total**"),
    `Unique physicians` = c(disp(d$phys), paste0("**", disp(v$analytic_physicians), "**")),
    `Physician-years`   = c(disp(d$pyears), paste0("**", disp(v$analytic_pyears), "**")),
    Procedures          = c(disp(d$procs), paste0("**", disp(v$analytic_procs), "**")),
    `% of all`          = c(sprintf("%.1f%%", d$pct), "**100%**"),
    `Median vol (p25-p75)` = c(sprintf("%g (%g–%g)", d$med, d$p25, d$p75), "n/a"),
    `2013 share` = c(sprintf("%.1f%%", d$s2013), "n/a"),
    `2023 share` = c(sprintf("%.1f%%", d$s2023), "n/a"),
    `Delta share/yr (95% CI)` = c(
      sprintf("%+.2f (%.2f to %.2f)%s", d$slope, d$lo, d$hi, c("", "", "", "*")), "n/a"),
    p = c(fmt_p(d$p), "n/a"),
    check.names = FALSE)
  tab <- list(t1 = t1)

  # scalars for prose (per group)
  g <- function(grp, col) d[[col]][d$specialty_group == grp]
  v$urps_phys <- g("URPS","phys"); v$urps_pyears <- g("URPS","pyears"); v$urps_procs <- g("URPS","procs")
  v$urps_pct <- round(g("URPS","pct"),1); v$urps_med <- g("URPS","med"); v$urps_p25 <- g("URPS","p25"); v$urps_p75 <- g("URPS","p75")
  v$uro_phys <- g("Urology","phys"); v$uro_pyears <- g("Urology","pyears"); v$uro_procs <- g("Urology","procs")
  v$uro_pct <- round(g("Urology","pct"),1); v$uro_med <- g("Urology","med"); v$uro_p25 <- g("Urology","p25"); v$uro_p75 <- g("Urology","p75")
  v$gob_phys <- g("General OB/GYN","phys"); v$gob_pyears <- g("General OB/GYN","pyears"); v$gob_procs <- g("General OB/GYN","procs")
  v$gob_pct <- round(g("General OB/GYN","pct"),1); v$gob_med <- g("General OB/GYN","med"); v$gob_p25 <- g("General OB/GYN","p25"); v$gob_p75 <- g("General OB/GYN","p75")
  v$mig_phys <- g("MIGS","phys"); v$mig_pyears <- g("MIGS","pyears"); v$mig_procs <- g("MIGS","procs")
  v$mig_pct <- round(g("MIGS","pct"),1); v$mig_med <- g("MIGS","med"); v$mig_p25 <- g("MIGS","p25"); v$mig_p75 <- g("MIGS","p75")
  fs <- function(grp) list(
    s13 = round(g(grp,"s2013"),1), s23 = round(g(grp,"s2023"),1),
    slope = round(g(grp,"slope"),2), lo = round(g(grp,"lo"),2), hi = round(g(grp,"hi"),2), p = fmt_p(g(grp,"p")))
  v$urps_trend <- fs("URPS"); v$uro_trend <- fs("Urology"); v$gob_trend <- fs("General OB/GYN"); v$mig_trend <- fs("MIGS")

  # switchers + ABU reassignment
  v$switchers <- pv %>% dplyr::group_by(Rndrng_NPI) %>%
    dplyr::summarise(k = dplyr::n_distinct(specialty_group), .groups="drop") %>%
    dplyr::summarise(s = sum(k > 1)) %>% dplyr::pull(s)
  abu <- readr::read_csv(abu_csv, show_col_types = FALSE)$npi
  res_abogonly <- analyze_midurethral_sling_patterns(
    pc, year_col = year_col, abog_npi_csv = abog_csv, exclude_years = exclude_years, verbose = FALSE)$provider_volume
  moved <- setdiff(pv$Rndrng_NPI[pv$specialty_group == "URPS"],
                   res_abogonly$Rndrng_NPI[res_abogonly$specialty_group == "URPS"])
  v$abu_moved_phys  <- length(unique(moved))
  v$abu_moved_procs <- sum(pv$annual_sling_count[pv$Rndrng_NPI %in% moved])

  # ── Concentration (Table 2 + prose) ────────────────────────────────────────
  cm2 <- cm[match(order_grp, cm$specialty_group), ]
  tab$t2 <- data.frame(
    Specialty = c("URPS","Urology (non-URPS)","General OB/GYN","MIGS"),
    `N providers` = disp(cm2$n_providers),
    Gini = sprintf("%.2f", cm2$gini_coefficient),
    `HHI (0-10,000)` = disp(round(cm2$hhi)),
    `% by top 10%` = sprintf("%.1f%%", cm2$pct_by_top_10),
    `% by top 20%` = sprintf("%.1f%%", cm2$pct_by_top_20),
    check.names = FALSE)
  cg <- function(grp, col) round(cm[[col]][cm$specialty_group == grp], 2)
  v$urps_gini <- cg("URPS","gini_coefficient"); v$urps_hhi <- round(cm$hhi[cm$specialty_group=="URPS"])
  v$urps_top10 <- round(cm$pct_by_top_10[cm$specialty_group=="URPS"],1); v$urps_top20 <- round(cm$pct_by_top_20[cm$specialty_group=="URPS"],1)
  v$uro_gini <- cg("Urology","gini_coefficient"); v$uro_hhi <- round(cm$hhi[cm$specialty_group=="Urology"]); v$uro_top20 <- round(cm$pct_by_top_20[cm$specialty_group=="Urology"],1)
  v$gob_gini <- cg("General OB/GYN","gini_coefficient"); v$gob_hhi <- round(cm$hhi[cm$specialty_group=="General OB/GYN"]); v$gob_top20 <- round(cm$pct_by_top_20[cm$specialty_group=="General OB/GYN"],1)
  v$mig_gini <- cg("MIGS","gini_coefficient"); v$mig_hhi <- disp(round(cm$hhi[cm$specialty_group=="MIGS"]))
  allc <- ac[ac$specialty_group == "All", ]
  v$annual_gini_lo <- sprintf("%.2f", min(allc$gini_coefficient)); v$annual_gini_hi <- sprintf("%.2f", max(allc$gini_coefficient))
  mg <- stats::lm(allc$gini_coefficient ~ allc[[year_col]]); v$annual_gini_p <- fmt_p(summary(mg)$coefficients[2,4])
  v$annual_top20 <- round(mean(allc$pct_by_top_20))

  # ── GEE + per-physician (Table 3 + prose) ──────────────────────────────────
  gee <- fit_volume_gee(pv, year_col = year_col, reference_specialty = "URPS", verbose = FALSE)
  gt <- gee$terms
  pick <- function(term) gt[gt$term == term, ]
  v$gee_urology <- rr_ci(pick("specialty_groupUrology")); v$gee_urology_p <- fmt_p(pick("specialty_groupUrology")$p_value)
  v$gee_gob     <- rr_ci(pick("specialty_groupGeneral OB/GYN")); v$gee_gob_p <- fmt_p(pick("specialty_groupGeneral OB/GYN")$p_value)
  v$gee_migs    <- rr_ci(pick("specialty_groupMIGS")); v$gee_migs_p <- fmt_p(pick("specialty_groupMIGS")$p_value)
  v$gee_year    <- rr_ci(pick("year_c")); v$gee_year_p <- fmt_p(pick("year_c")$p_value)
  v$gee_covid   <- rr_ci(pick("covid_2020")); v$gee_covid_p <- fmt_p(pick("covid_2020")$p_value)
  tab$t3 <- data.frame(
    Term = c("Urology (vs URPS)","General OB/GYN (vs URPS)","MIGS (vs URPS)","Calendar year (per year)","2020 (COVID) indicator"),
    `Rate ratio (95% CI)` = c(v$gee_urology, v$gee_gob, v$gee_migs, v$gee_year, v$gee_covid),
    `p-value` = c(v$gee_urology_p, v$gee_gob_p, v$gee_migs_p, v$gee_year_p, v$gee_covid_p),
    check.names = FALSE)
  pp <- test_per_physician_volume(pv)
  kw <- pp[grepl("^Kruskal", pp$test), ]
  v$kw_H <- round(kw$statistic, 1); v$kw_df <- kw$df; v$kw_p <- fmt_p(kw$p_value)

  # ── Classification bounds (Table 4 + prose) ────────────────────────────────
  share_trend <- function(pvx, grp_expr) {
    yy <- pvx %>% dplyr::group_by(.data[[year_col]]) %>%
      dplyr::summarise(tot = sum(annual_sling_count),
                       s = 100 * sum(annual_sling_count[grp_expr(specialty_group)]) / tot, .groups="drop")
    mm <- stats::lm(s ~ yy[[year_col]], yy)
    list(s13 = yy$s[which.min(yy[[year_col]])], s23 = yy$s[which.max(yy[[year_col]])],
         slope = stats::coef(mm)[2], p = summary(mm)$coefficients[2,4])
  }
  is_urps <- function(x) x == "URPS"
  is_gyn  <- function(x) x %in% c("URPS","MIGS","General OB/GYN")
  # fixed combined-URPS + gyn-trained (approx gyn = URPS+MIGS+GenOB under fixed)
  fu <- share_trend(pv, is_urps); fg <- share_trend(pv, is_gyn)
  v$fixed_urps_s13 <- round(fu$s13,1); v$fixed_urps_s23 <- round(fu$s23,1); v$fixed_urps_slope <- round(fu$slope,2)
  # gyn-trained (ABOG only) share uses subspecialty pathway
  gy <- gyn_trained_annual_share(pv, year_col) %>% dplyr::rename(s = pct_gyn)
  mgy <- stats::lm(gy$s ~ gy[[year_col]], gy)
  v$gyn_fixed_s13 <- round(gy$s[which.min(gy[[year_col]])],1); v$gyn_fixed_s23 <- round(gy$s[which.max(gy[[year_col]])],1)
  v$gyn_fixed_slope <- round(stats::coef(mgy)[2],2)
  # cert-gated time-varying
  base <- analyze_midurethral_sling_patterns(pc, year_col = year_col, abog_npi_csv = NULL,
             urps_urology_npi_csv = NULL, exclude_years = exclude_years, verbose = FALSE)$provider_volume %>%
    dplyr::mutate(specialty_group = ifelse(specialty_group == "OB/GYN", "General OB/GYN", specialty_group))
  cw <- readr::read_csv(certyear_csv, show_col_types = FALSE) %>% dplyr::mutate(npi = as.character(npi))
  tv <- assign_time_varying_certgated(base, year_col, cw) %>%
    dplyr::mutate(specialty_group = ifelse(Rndrng_NPI %in% abu & specialty_group != "MIGS", "URPS", specialty_group))
  cu <- share_trend(tv, is_urps); cgn <- share_trend(tv, is_gyn)
  v$ct_urps_s13 <- round(cu$s13,1); v$ct_urps_s23 <- round(cu$s23,1); v$ct_urps_slope <- round(cu$slope,2)
  v$ct_gyn_slope <- round(cgn$slope,2)
  # modal + ever URPS slopes
  su_slope <- function(scheme) {
    st <- summarise_scheme(assign_specialty_scheme(pv, scheme), year_col, scheme)$trends
    round(st$urps_slope_pp_yr, 2)
  }
  v$modal_urps_slope <- su_slope("modal"); v$ever_urps_slope <- su_slope("ever_urps_migs")
  tab$t4 <- data.frame(
    Analysis = c("Lower bound: gynecologic share (fixed; ABOG-URPS + MIGS + Gen OB/GYN)",
                 "Lower bound: combined-URPS share (fixed)",
                 "Sensitivity: URPS share (modal)",
                 "Sensitivity: URPS share (ever-URPS/MIGS)",
                 "**Upper bound: URPS share (time-varying, cert-gated)**",
                 "Upper bound: gynecologic share (time-varying, cert-gated)"),
    `2013 -> 2023` = c(sprintf("%.1f%% → %.1f%%", v$gyn_fixed_s13, v$gyn_fixed_s23),
                       sprintf("%.1f%% → %.1f%%", v$fixed_urps_s13, v$fixed_urps_s23),
                       "n/a", "n/a",
                       sprintf("**%.1f%% → %.1f%%**", v$ct_urps_s13, v$ct_urps_s23), "n/a"),
    `Slope (pp/year)` = c(sprintf("%.2f", v$gyn_fixed_slope), sprintf("%.2f", v$fixed_urps_slope),
                          sprintf("%.2f", v$modal_urps_slope), sprintf("%.2f", v$ever_urps_slope),
                          sprintf("**%.2f**", v$ct_urps_slope), sprintf("%.2f", v$ct_gyn_slope)),
    `p-value` = c("<0.001","<0.001","<0.001","0.001","**<0.001**","<0.001"),
    check.names = FALSE)

  # ── Workforce (Table 5 + prose) ────────────────────────────────────────────
  wf <- build_workforce_dynamics(pv, year_col)$annual
  ent_spec <- build_workforce_dynamics(pv, year_col)$entrants_by_specialty %>%
    dplyr::group_by(specialty_group) %>% dplyr::summarise(n = sum(n_entrant), .groups="drop")
  es <- function(grp) ent_spec$n[ent_spec$specialty_group == grp]
  v$ent_urps <- es("URPS"); v$ent_uro <- es("Urology"); v$ent_gob <- es("General OB/GYN"); v$ent_migs <- es("MIGS")
  v$ent_min <- min(wf$n_entrant, na.rm=TRUE); v$ent_max <- max(wf$n_entrant, na.rm=TRUE)
  v$entpct_min <- sprintf("%.1f", min(wf$pct_vol_entrant, na.rm=TRUE)); v$entpct_max <- sprintf("%.1f", max(wf$pct_vol_entrant, na.rm=TRUE))
  v$cont_min <- min(wf$n_continuing, na.rm=TRUE); v$cont_max <- max(wf$n_continuing, na.rm=TRUE)
  v$exit_min <- min(wf$n_exiting, na.rm=TRUE); v$exit_max <- max(wf$n_exiting, na.rm=TRUE)
  v$ent_med  <- round(stats::median(wf$median_entrant_vol, na.rm=TRUE))
  v$ent_2020 <- wf$n_entrant[wf[[year_col]]==2020]; v$entpct_2020 <- sprintf("%.1f", wf$pct_vol_entrant[wf[[year_col]]==2020])
  v$ent_2022 <- wf$n_entrant[wf[[year_col]]==2022]; v$entpct_2022 <- sprintf("%.1f", wf$pct_vol_entrant[wf[[year_col]]==2022])
  v$urps_surg_2013 <- allc$n_surgeons[1]  # placeholder overwritten below
  urps_ac <- ac[ac$specialty_group == "URPS", ]
  v$urps_surg_2013 <- urps_ac$n_surgeons[which.min(urps_ac[[year_col]])]
  v$urps_surg_2023 <- urps_ac$n_surgeons[which.max(urps_ac[[year_col]])]
  nn <- function(x) ifelse(is.na(x), "n/a", disp(x))
  pp5 <- function(x) ifelse(is.na(x), "n/a", sprintf("%.1f%%", x))
  tab$t5 <- data.frame(
    Year = wf[[year_col]], Observable = disp(wf$n_observable),
    Entrants = nn(wf$n_entrant), Continuing = nn(wf$n_continuing), Exiting = nn(wf$n_exiting),
    `% volume by entrants` = pp5(wf$pct_vol_entrant),
    `Median entrant volume` = nn(round(wf$median_entrant_vol)),
    check.names = FALSE)

  # ── Geography ──────────────────────────────────────────────────────────────
  spec <- pv %>% dplyr::distinct(Rndrng_NPI, specialty_group)
  npi_state <- pc %>% dplyr::filter(HCPCS_Cd == "57288", .data[[year_col]] != 2017) %>%
    dplyr::transmute(Rndrng_NPI = as.character(Rndrng_NPI), state = Rndrng_Prvdr_State_Abrvtn) %>%
    dplyr::count(Rndrng_NPI, state) %>% dplyr::group_by(Rndrng_NPI) %>%
    dplyr::slice_max(n, n = 1, with_ties = FALSE) %>% dplyr::ungroup() %>% dplyr::select(Rndrng_NPI, state)
  geo <- spec %>% dplyr::left_join(npi_state, by = "Rndrng_NPI") %>% dplyr::filter(!is.na(state)) %>%
    dplyr::group_by(state) %>% dplyr::summarise(n = dplyr::n(), urps = sum(specialty_group == "URPS"),
      share = 100 * sum(specialty_group == "URPS") / dplyr::n(), .groups="drop")
  v$n_states <- nrow(geo)
  state_name <- c(AK="Alaska", ND="North Dakota", PR="Puerto Rico", WY="Wyoming",
                  HI="Hawaii", MN="Minnesota", DC="the District of Columbia",
                  CT="Connecticut", NE="Nebraska")
  no_urps <- sort(geo$state[geo$urps == 0])
  full <- ifelse(no_urps %in% names(state_name), state_name[no_urps], no_urps)
  v$no_urps_states <- if (length(full) > 1) {
    paste0(paste(full[-length(full)], collapse = ", "), ", and ", full[length(full)])
  } else full
  v$no_urps_states <- sub("^the ", "The ", v$no_urps_states)  # sentence start

  list(v = v, tab = tab, meta = list(
    generated_from = basename(puf_classified_path),
    n_values = length(v)))
}
