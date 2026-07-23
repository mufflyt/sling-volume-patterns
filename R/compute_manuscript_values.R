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
    denom_csv    = NULL,
    exclude_years = NULL,
    year_col      = "puf_year",
    r_dir         = "R"
) {
  `%>%` <- dplyr::`%>%`
  # Default: honour config exclude_years (empty now that the complete 2017 file
  # is in the cache). Pass an explicit vector to override.
  if (is.null(exclude_years)) {
    exclude_years <- tryCatch(as.integer(unlist(config::get("exclude_years"))),
                              error = function(e) integer(0))
  }
  source(file.path(r_dir, "reporting_stats_helpers.R"), local = TRUE)
  source(file.path(r_dir, "analyze_sling_patterns.R"),  local = TRUE)
  source(file.path(r_dir, "classification_schemes.R"),  local = TRUE)
  source(file.path(r_dir, "workforce_dynamics.R"),      local = TRUE)
  source(file.path(r_dir, "volume_models.R"),           local = TRUE)
  source(file.path(r_dir, "build_ffs_denominator.R"),   local = TRUE)
  source(file.path(r_dir, "specialty_groups.R"),        local = TRUE)
  source(file.path(r_dir, "manuscript_sections.R"),     local = TRUE)

  pc <- readRDS(puf_classified_path)

  # ── Analyses: full (all years) and analytic (config exclude_years; now none) ─
  # Classification options come from config (single source of truth), so the
  # manuscript numbers and the pipeline cache use identical grouping (reviewer
  # #3/#4: main and supplementary outputs cannot drift).
  copts <- classification_opts()
  run_analyze <- function(excl) analyze_midurethral_sling_patterns(
    pc, year_col = year_col, abog_npi_csv = abog_csv, urps_urology_npi_csv = abu_csv,
    exclude_years = excl, other_handling = copts$other_handling,
    split_urps_pathway = copts$split_urps_pathway, verbose = FALSE)
  res <- run_analyze(exclude_years)
  # res_full (all years) equals res when no years are excluded; avoid re-running.
  res_full <- if (length(exclude_years) == 0L) res else run_analyze(NULL)
  pv   <- res$provider_volume
  pvf  <- res_full$provider_volume
  tt   <- res$time_trends
  cm   <- res$concentration_metrics
  ac   <- res$annual_concentration
  ca <- res$classification_audit  # classification transparency counts (reviewer #5)

  fmt_p  <- function(p) ifelse(is.na(p), "n/a", ifelse(p < 0.001, "<0.001", sprintf("%.3f", p)))
  rr_ci  <- function(row) sprintf("%.2f (%.2f–%.2f)", row$rate_ratio, row$ci_low, row$ci_high)
  yr_val <- function(df, y, col) df[[col]][df[[year_col]] == y]

  v <- list()
  v$class_reclass_urology   <- ca$reclassified_other_to_urology
  v$class_abu_pathway       <- ca$urps_via_abu_pathway
  v$class_excluded_other    <- ca$excluded_other_records
  v$class_excluded_facility <- ca$excluded_facility_npis

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

  # ── Denominator-adjusted rate (reviewer #2) ────────────────────────────────
  # Rate = CPT 57288 services per 100,000 female Part B fee-for-service Medicare
  # beneficiaries. Original Medicare = FFS, matching the PUF numerator. Adjusting
  # for the shrinking FFS denominator separates a falling count from falling use.
  denom <- tryCatch(read_ffs_denominator(denom_csv), error = function(e) NULL)
  v$has_denominator <- !is.null(denom)
  if (v$has_denominator) {
    rate_tbl <- attach_ffs_rate(
      data.frame(year = yr[[year_col]], services = yr$procs),
      year_col = "year", services_col = "services", denom = denom)
    rget <- function(y) rate_tbl$rate_per_100k[rate_tbl$year == y]
    dget <- function(y) rate_tbl$denominator[rate_tbl$year == y]
    v$rate_2013 <- round(rget(2013), 1); v$rate_2020 <- round(rget(2020), 1)
    v$rate_2022 <- round(rget(2022), 1); v$rate_2023 <- round(rget(2023), 1)
    v$den_2013_m <- round(dget(2013) / 1e6, 2); v$den_2023_m <- round(dget(2023) / 1e6, 2)
    v$den_pct_change <- round(100 * (dget(2023) / dget(2013) - 1), 1)
    mr <- stats::lm(rate_per_100k ~ year, rate_tbl)
    v$rate_slope   <- round(stats::coef(mr)[2], 2)
    v$rate_slope_p <- fmt_p(summary(mr)$coefficients[2, 4])
    v$rate_pct_change   <- round(100 * (rget(2023) / rget(2013) - 1), 1)
    v$count_pct_change  <- round(100 * (v$procs_2023 / v$procs_2013 - 1), 1)
  }

  # ── Specialty distribution + per-specialty share trends (Table 1) ──────────
  # order_grp = the well-populated specialty groups used for concentration and
  # model displays. order_grp1 = Table 1 rows, which also show the excluded-from-
  # inference "Other/uncertain" group (reviewer: facilities and non-physician
  # clinicians must not be silently folded into urology).
  # Group ordering and labels come from the central taxonomy (specialty_groups.R):
  # order_grp = the inferential groups (Table 2/3), order_grp1 = every group
  # (Table 1). "URPS (OB/GYN)" is the primary/reference URPS group.
  # Restrict to groups actually present (e.g. "exclude" mode drops Other/uncertain).
  present    <- unique(as.character(pv$specialty_group))
  order_grp  <- intersect(sg_codes("inferential"),  present)
  order_grp1 <- intersect(sg_codes("distribution"), present)
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
  d <- d[match(order_grp1, d$specialty_group), ]

  disp <- function(x) format(x, big.mark = ",")
  astk <- ifelse(order_grp1 == "MIGS", "*", "")
  t1 <- data.frame(
    Specialty = c(sg_display(order_grp1), "**Total**"),
    `Unique physicians` = c(disp(d$phys), paste0("**", disp(v$analytic_physicians), "**")),
    `Physician-years`   = c(disp(d$pyears), paste0("**", disp(v$analytic_pyears), "**")),
    `Reported services` = c(disp(d$procs), paste0("**", disp(v$analytic_procs), "**")),
    `% of all`          = c(sprintf("%.1f%%", d$pct), "**100%**"),
    `Median vol (p25-p75)` = c(sprintf("%g (%g–%g)", d$med, d$p25, d$p75), "n/a"),
    `2013 share` = c(sprintf("%.1f%%", d$s2013), "n/a"),
    `2023 share` = c(sprintf("%.1f%%", d$s2023), "n/a"),
    `Delta share/yr (95% CI)` = c(
      sprintf("%+.2f (%.2f to %.2f)%s", d$slope, d$lo, d$hi, astk), "n/a"),
    p = c(fmt_p(d$p), "n/a"),
    check.names = FALSE)
  tab <- list(t1 = t1)
  # Other/uncertain scalars for the classification-flow prose. The primary
  # cohort excludes these billers (other_handling = "exclude"), so they are
  # absent from `dist`; we recover the count and observable-service share from a
  # "separate" run purely to describe how many individuals were set aside for
  # the sensitivity analysis (Supplementary Table S11).
  ou <- dist[dist$specialty_group == "Other/uncertain", ]
  if (!nrow(ou)) {
    rr_sep <- analyze_midurethral_sling_patterns(
      pc, year_col = year_col, abog_npi_csv = abog_csv, urps_urology_npi_csv = abu_csv,
      exclude_years = exclude_years, other_handling = "separate", verbose = FALSE)$provider_volume
    tot_sep <- sum(rr_sep$annual_sling_count)
    ou_sep <- rr_sep[rr_sep$specialty_group == "Other/uncertain", ]
    ou <- data.frame(
      phys  = dplyr::n_distinct(ou_sep$Rndrng_NPI),
      procs = sum(ou_sep$annual_sling_count),
      pct   = 100 * sum(ou_sep$annual_sling_count) / tot_sep)
  }
  v$other_phys <- if (nrow(ou)) ou$phys else 0
  v$other_procs <- if (nrow(ou)) ou$procs else 0
  v$other_pct <- if (nrow(ou)) round(ou$pct, 1) else 0

  # Classification sensitivity (reviewer #1): how the URPS and urology shares
  # move across the three ways of handling the ambiguous/facility billers.
  classif_row <- function(mode, label) {
    rr <- analyze_midurethral_sling_patterns(
      pc, year_col = year_col, abog_npi_csv = abog_csv, urps_urology_npi_csv = abu_csv,
      exclude_years = exclude_years, other_handling = mode, verbose = FALSE)$provider_volume
    tot <- sum(rr$annual_sling_count)
    sh <- function(g) 100 * sum(rr$annual_sling_count[rr$specialty_group == g]) / tot
    data.frame(
      `Handling of ambiguous billers` = label,
      `Physicians` = disp(dplyr::n_distinct(rr$Rndrng_NPI)),
      `URPS share` = sprintf("%.1f%%", sh("URPS")),
      `Non-URPS urology share` = sprintf("%.1f%%", sh("Urology")),
      check.names = FALSE, row.names = NULL)
  }
  tab$t_classif_sens <- rbind(
    classif_row("exclude",  "Excluded from the cohort (primary)"),
    classif_row("separate", "Retained as a separate 'Other/uncertain' group"),
    classif_row("urology",  "Assigned to urology (legacy)"))

  # scalars for prose (per group). v$urps_* = OB/GYN-pathway URPS (primary URPS
  # group and GEE reference); v$urpsuro_* = urology-pathway URPS.
  g <- function(grp, col) d[[col]][d$specialty_group == grp]
  v$urps_phys <- g("URPS (OB/GYN)","phys"); v$urps_pyears <- g("URPS (OB/GYN)","pyears"); v$urps_procs <- g("URPS (OB/GYN)","procs")
  v$urps_pct <- round(g("URPS (OB/GYN)","pct"),1); v$urps_med <- g("URPS (OB/GYN)","med"); v$urps_p25 <- g("URPS (OB/GYN)","p25"); v$urps_p75 <- g("URPS (OB/GYN)","p75")
  v$urpsuro_phys <- g("URPS (urology)","phys"); v$urpsuro_procs <- g("URPS (urology)","procs")
  v$urpsuro_pct <- round(g("URPS (urology)","pct"),1); v$urpsuro_med <- g("URPS (urology)","med")
  v$urpsuro_p25 <- g("URPS (urology)","p25"); v$urpsuro_p75 <- g("URPS (urology)","p75")
  v$urps_combined_pct <- round(v$urps_pct + v$urpsuro_pct, 1)
  v$uro_phys <- g("Urology","phys"); v$uro_pyears <- g("Urology","pyears"); v$uro_procs <- g("Urology","procs")
  v$uro_pct <- round(g("Urology","pct"),1); v$uro_med <- g("Urology","med"); v$uro_p25 <- g("Urology","p25"); v$uro_p75 <- g("Urology","p75")
  v$gob_phys <- g("General OB/GYN","phys"); v$gob_pyears <- g("General OB/GYN","pyears"); v$gob_procs <- g("General OB/GYN","procs")
  v$gob_pct <- round(g("General OB/GYN","pct"),1); v$gob_med <- g("General OB/GYN","med"); v$gob_p25 <- g("General OB/GYN","p25"); v$gob_p75 <- g("General OB/GYN","p75")
  v$mig_phys <- g("MIGS","phys"); v$mig_pyears <- g("MIGS","pyears"); v$mig_procs <- g("MIGS","procs")
  v$mig_pct <- round(g("MIGS","pct"),1); v$mig_med <- g("MIGS","med"); v$mig_p25 <- g("MIGS","p25"); v$mig_p75 <- g("MIGS","p75")
  fs <- function(grp) list(
    s13 = round(g(grp,"s2013"),1), s23 = round(g(grp,"s2023"),1),
    slope = round(g(grp,"slope"),2), lo = round(g(grp,"lo"),2), hi = round(g(grp,"hi"),2), p = fmt_p(g(grp,"p")))
  v$urps_trend <- fs("URPS (OB/GYN)"); v$urpsuro_trend <- fs("URPS (urology)")
  v$uro_trend <- fs("Urology"); v$gob_trend <- fs("General OB/GYN"); v$mig_trend <- fs("MIGS")

  # switchers; ABU (urology-pathway) URPS = the "URPS (urology)" group.
  v$switchers <- pv %>% dplyr::group_by(Rndrng_NPI) %>%
    dplyr::summarise(k = dplyr::n_distinct(specialty_group), .groups="drop") %>%
    dplyr::summarise(s = sum(k > 1)) %>% dplyr::pull(s)
  abu <- readr::read_csv(abu_csv, show_col_types = FALSE)$npi
  v$abu_moved_phys  <- v$urpsuro_phys
  v$abu_moved_procs <- v$urpsuro_procs

  # ── Concentration (Table 2 + prose) ────────────────────────────────────────
  cm2 <- cm[match(order_grp, cm$specialty_group), ]
  # Per-NPI pooled volume vectors per specialty, for bootstrap CIs (reviewer #3).
  npi_tot <- pv %>% dplyr::group_by(specialty_group, Rndrng_NPI) %>%
    dplyr::summarise(vv = sum(annual_sling_count), .groups = "drop")
  vec <- function(grp) npi_tot$vv[npi_tot$specialty_group == grp]
  gini_ci <- function(grp) bootstrap_concentration_ci(vec(grp), compute_gini)
  tab$t2 <- data.frame(
    Specialty = sg_display(order_grp),
    `N providers` = disp(cm2$n_providers),
    Gini = sprintf("%.2f", cm2$gini_coefficient),
    `HHI (0-10,000)` = disp(round(cm2$hhi)),
    `Normalized HHI` = ifelse(is.na(cm2$hhi_normalized), "n/a",
                              sprintf("%.3f", cm2$hhi_normalized)),
    `Effective providers` = ifelse(is.na(cm2$effective_providers), "n/a",
                                   disp(round(cm2$effective_providers))),
    `% by top 10%` = sprintf("%.1f%%", cm2$pct_by_top_10),
    `% by top 20%` = sprintf("%.1f%%", cm2$pct_by_top_20),
    check.names = FALSE)
  cg <- function(grp, col) round(cm[[col]][cm$specialty_group == grp], 2)
  cn <- function(grp, col) cm[[col]][cm$specialty_group == grp]
  fmt_gini_ci <- function(grp) { ci <- gini_ci(grp)
    sprintf("%.2f (95%% CI %.2f-%.2f)", cn(grp,"gini_coefficient"), ci[1], ci[2]) }
  UOBG <- "URPS (OB/GYN)"
  v$urps_gini <- cg(UOBG,"gini_coefficient"); v$urps_hhi <- round(cm$hhi[cm$specialty_group==UOBG])
  v$urps_top10 <- round(cm$pct_by_top_10[cm$specialty_group==UOBG],1); v$urps_top20 <- round(cm$pct_by_top_20[cm$specialty_group==UOBG],1)
  v$urpsuro_gini <- cg("URPS (urology)","gini_coefficient"); v$urpsuro_top20 <- round(cm$pct_by_top_20[cm$specialty_group=="URPS (urology)"],1)
  v$uro_gini <- cg("Urology","gini_coefficient"); v$uro_hhi <- round(cm$hhi[cm$specialty_group=="Urology"]); v$uro_top20 <- round(cm$pct_by_top_20[cm$specialty_group=="Urology"],1)
  v$gob_gini <- cg("General OB/GYN","gini_coefficient"); v$gob_hhi <- round(cm$hhi[cm$specialty_group=="General OB/GYN"]); v$gob_top20 <- round(cm$pct_by_top_20[cm$specialty_group=="General OB/GYN"],1)
  v$mig_gini <- cg("MIGS","gini_coefficient"); v$mig_hhi <- disp(round(cm$hhi[cm$specialty_group=="MIGS"]))
  # Normalized HHI, effective providers, and Gini bootstrap CIs (reviewer #3)
  v$urps_hhi_norm <- sprintf("%.3f", cn(UOBG,"hhi_normalized"))
  v$uro_hhi_norm  <- sprintf("%.3f", cn("Urology","hhi_normalized"))
  v$gob_hhi_norm  <- sprintf("%.3f", cn("General OB/GYN","hhi_normalized"))
  v$urps_effn <- round(cn(UOBG,"effective_providers"))
  v$uro_effn  <- round(cn("Urology","effective_providers"))
  v$gob_effn  <- round(cn("General OB/GYN","effective_providers"))
  v$urps_gini_ci <- fmt_gini_ci(UOBG)
  v$urpsuro_gini_ci <- fmt_gini_ci("URPS (urology)")
  v$uro_gini_ci  <- fmt_gini_ci("Urology")
  v$gob_gini_ci  <- fmt_gini_ci("General OB/GYN")

  # Suppression sensitivity (reviewer #3): the PUF omits physician-years below
  # 11 beneficiaries. Add hypothetical suppressed providers (a fraction of the
  # observed count) each at low volume (services spread over 1-10) and recompute
  # Gini/HHI, to bound how the unobserved tail could move the estimates.
  supp_sens <- function(grp, frac) {
    x <- vec(grp); n <- length(x)
    k <- round(frac * n)
    add <- rep_len(1:10, k)
    y <- c(x, add)
    c(gini = compute_gini(y), hhi = compute_hhi(y))
  }
  tab$t_suppress <- do.call(rbind, lapply(
    c("URPS (OB/GYN)","URPS (urology)","Urology","General OB/GYN"), function(g) {
      obs <- c(gini = cn(g,"gini_coefficient"), hhi = cn(g,"hhi"))
      s25 <- supp_sens(g, 0.25); s50 <- supp_sens(g, 0.50)
      data.frame(
        Specialty = dplyr::case_when(g=="Urology"~"Urology (non-URPS)", g=="General OB/GYN"~"Other non-URPS OB/GYN", TRUE~g),
        `Observed Gini` = sprintf("%.2f", obs["gini"]),
        `Gini +25% suppressed` = sprintf("%.2f", s25["gini"]),
        `Gini +50% suppressed` = sprintf("%.2f", s50["gini"]),
        `Observed HHI` = round(obs["hhi"]),
        `HHI +50% suppressed` = round(s50["hhi"]),
        check.names = FALSE, row.names = NULL)
    }))
  allc <- ac[ac$specialty_group == "All", ]
  v$annual_gini_lo <- sprintf("%.2f", min(allc$gini_coefficient)); v$annual_gini_hi <- sprintf("%.2f", max(allc$gini_coefficient))
  mg <- stats::lm(allc$gini_coefficient ~ allc[[year_col]]); v$annual_gini_p <- fmt_p(summary(mg)$coefficients[2,4])
  v$annual_top20 <- round(mean(allc$pct_by_top_20))
  # Within-year (annual) Gini per specialty (reviewer #7: the abstract must
  # report the annual, not pooled, Gini when it calls within-year concentration
  # the primary measure). These are ~0.24-0.28, not the pooled 0.52-0.56.
  ann_gini <- function(grp) {
    x <- ac$gini_coefficient[ac$specialty_group == grp]
    if (length(x) == 0) NA_real_ else mean(x, na.rm = TRUE)
  }
  v$annual_gini_urps <- sprintf("%.2f", ann_gini("URPS (OB/GYN)"))
  v$annual_gini_uro  <- sprintf("%.2f", ann_gini("Urology"))
  v$annual_gini_gob  <- sprintf("%.2f", ann_gini("General OB/GYN"))
  v$annual_gini_spec_lo <- sprintf("%.2f", min(c(ann_gini("URPS (OB/GYN)"), ann_gini("URPS (urology)"), ann_gini("Urology"), ann_gini("General OB/GYN")), na.rm=TRUE))
  v$annual_gini_spec_hi <- sprintf("%.2f", max(c(ann_gini("URPS (OB/GYN)"), ann_gini("URPS (urology)"), ann_gini("Urology"), ann_gini("General OB/GYN")), na.rm=TRUE))

  # Pairwise pooled-Gini difference bootstrap CIs (reviewer #8: overlapping
  # individual CIs are not a test of between-group difference). Also the
  # effective-provider fraction (effective N / actual N).
  boot_gini_diff <- function(a, b, R = 2000L, seed = 7L) {
    a <- a[!is.na(a)]; b <- b[!is.na(b)]
    old <- if (exists(".Random.seed", envir = .GlobalEnv)) get(".Random.seed", envir = .GlobalEnv) else NULL
    set.seed(seed); on.exit(if (!is.null(old)) assign(".Random.seed", old, envir = .GlobalEnv))
    dd <- vapply(seq_len(R), function(i)
      compute_gini(a[sample.int(length(a), length(a), TRUE)]) -
      compute_gini(b[sample.int(length(b), length(b), TRUE)]), numeric(1))
    c(est = compute_gini(a) - compute_gini(b), unname(stats::quantile(dd, c(.025, .975), na.rm = TRUE)))
  }
  gd <- function(g1, g2) { r <- boot_gini_diff(vec(g1), vec(g2))
    list(txt = sprintf("%+.3f (95%% CI %+.3f to %+.3f)", r[1], r[2], r[3]),
         differs = r[2] * r[3] > 0) }
  v$ginidiff_urps_gob <- gd("URPS (OB/GYN)", "General OB/GYN")
  v$ginidiff_urps_uro <- gd("URPS (OB/GYN)", "Urology")
  v$ginidiff_uro_gob  <- gd("Urology", "General OB/GYN")
  effpct <- function(grp) round(100 * cn(grp, "effective_providers") / cn(grp, "n_providers"))
  v$urps_effpct <- effpct("URPS (OB/GYN)"); v$uro_effpct <- effpct("Urology"); v$gob_effpct <- effpct("General OB/GYN")

  # Denominator-offset utilization model (reviewer #5/#6): annual services with
  # log FFS enrollment as an offset, dispersion-robust. Report the estimate and
  # CI, not just whether p<0.05; the point estimate is a meaningful decline.
  if (isTRUE(v$has_denominator)) {
    denom_tbl <- read_ffs_denominator(denom_csv)
    off <- pv %>% dplyr::group_by(year = .data[[year_col]]) %>%
      dplyr::summarise(services = sum(annual_sling_count), .groups = "drop") %>%
      dplyr::left_join(denom_tbl, by = "year") %>%
      dplyr::mutate(year_c = year - 2018, covid = as.integer(year == 2020))
    mo <- stats::glm(services ~ year_c + covid, family = stats::quasipoisson(),
                     offset = log(denominator), data = off)
    coo <- summary(mo)$coefficients
    b <- coo["year_c", "Estimate"]; se <- coo["year_c", "Std. Error"]
    v$rate_offset_rr    <- sprintf("%.3f", exp(b))
    v$rate_offset_ci    <- sprintf("%.3f-%.3f", exp(b - 1.96 * se), exp(b + 1.96 * se))
    v$rate_offset_pctyr <- sprintf("%.1f", 100 * (exp(b) - 1))
    v$rate_offset_decade<- sprintf("%.1f", 100 * (exp(b * 10) - 1))
    v$rate_offset_p     <- fmt_p(coo["year_c", "Pr(>|t|)"])
  }

  # ── GEE + per-physician (Table 3 + prose) ──────────────────────────────────
  # Poisson GEE clustered by NPI, year centered at 2018 (mid-study): specialty
  # main effects are the rate ratios vs URPS at mid-study; specialty-specific
  # annual slopes are the marginal year contrasts (year_c + specialty:year_c).
  # Reference = OB/GYN-pathway URPS (largest URPS group).
  gee <- fit_volume_gee(pv, year_col = year_col, reference_specialty = "URPS (OB/GYN)",
                        center_year = 2018, verbose = FALSE)
  gt <- gee$terms
  pick <- function(term) gt[gt$term == term, ]
  v$gee_urpsuro <- rr_ci(pick("specialty_groupURPS (urology)")); v$gee_urpsuro_p <- fmt_p(pick("specialty_groupURPS (urology)")$p_value)
  v$gee_urology <- rr_ci(pick("specialty_groupUrology")); v$gee_urology_p <- fmt_p(pick("specialty_groupUrology")$p_value)
  v$gee_gob     <- rr_ci(pick("specialty_groupGeneral OB/GYN")); v$gee_gob_p <- fmt_p(pick("specialty_groupGeneral OB/GYN")$p_value)
  v$gee_migs    <- rr_ci(pick("specialty_groupMIGS")); v$gee_migs_p <- fmt_p(pick("specialty_groupMIGS")$p_value)
  v$gee_covid   <- rr_ci(pick("covid_2020")); v$gee_covid_p <- fmt_p(pick("covid_2020")$p_value)
  # Specialty-specific annual slopes (marginal contrasts).
  sl <- specialty_year_slopes(gee$model, reference_specialty = "URPS (OB/GYN)")
  slrow <- function(grp) sl[sl$specialty == grp, ]
  slrr  <- function(grp) sprintf("%.3f (%.3f-%.3f)", slrow(grp)$slope_rr, slrow(grp)$ci_low, slrow(grp)$ci_high)
  v$slope_urps    <- slrr("URPS (OB/GYN)"); v$slope_urps_p <- fmt_p(slrow("URPS (OB/GYN)")$p_value)
  v$slope_urpsuro <- slrr("URPS (urology)"); v$slope_urpsuro_p <- fmt_p(slrow("URPS (urology)")$p_value)
  v$slope_uro  <- slrr("Urology"); v$slope_uro_p <- fmt_p(slrow("Urology")$p_value)
  v$slope_gob  <- slrr("General OB/GYN"); v$slope_gob_p <- fmt_p(slrow("General OB/GYN")$p_value)
  v$slope_migs <- slrr("MIGS"); v$slope_migs_p <- fmt_p(slrow("MIGS")$p_value)
  tab$t3 <- data.frame(
    Term = c("URPS urology vs URPS OB/GYN (at 2018)","Non-URPS urology vs URPS OB/GYN (at 2018)",
             "Other non-URPS OB/GYN vs URPS OB/GYN (at 2018)","MIGS vs URPS OB/GYN (at 2018)",
             "2020 (COVID) indicator",
             "Annual trend, URPS (OB/GYN)","Annual trend, URPS (urology)","Annual trend, non-URPS urology",
             "Annual trend, other non-URPS OB/GYN","Annual trend, MIGS"),
    `Rate ratio (95% CI)` = c(v$gee_urpsuro, v$gee_urology, v$gee_gob, v$gee_migs, v$gee_covid,
                              v$slope_urps, v$slope_urpsuro, v$slope_uro, v$slope_gob, v$slope_migs),
    `p-value` = c(v$gee_urpsuro_p, v$gee_urology_p, v$gee_gob_p, v$gee_migs_p, v$gee_covid_p,
                  v$slope_urps_p, v$slope_urpsuro_p, v$slope_uro_p, v$slope_gob_p, v$slope_migs_p),
    check.names = FALSE)
  # Negative-binomial mixed model sensitivity (report numbers, not "concordant")
  nb <- tryCatch(fit_volume_nb_mixed(pv, year_col = year_col, reference_specialty = "URPS (OB/GYN)",
                                     center_year = 2018, verbose = FALSE), error = function(e) NULL)
  v$has_nb <- !is.null(nb)
  if (v$has_nb) {
    nbpick <- function(term) nb$terms[nb$terms$term == term, ]
    v$nb_urology <- rr_ci(nbpick("specialty_groupUrology"))
    v$nb_gob     <- rr_ci(nbpick("specialty_groupGeneral OB/GYN"))
    v$nb_migs    <- rr_ci(nbpick("specialty_groupMIGS"))
    v$nb_covid   <- rr_ci(nbpick("covid_2020"))
  }
  pp <- test_per_physician_volume(pv)
  kw <- pp[grepl("^Kruskal", pp$test), ]
  v$kw_H <- round(kw$statistic, 1); v$kw_df <- kw$df; v$kw_p <- fmt_p(kw$p_value)

  # ── Binomial URPS-share model (reviewer #4) ────────────────────────────────
  # Model OB/GYN-pathway URPS services out of all annual services (the primary
  # URPS group) with a quasibinomial GLM on year.
  ash <- pv %>% dplyr::group_by(year = .data[[year_col]]) %>%
    dplyr::summarise(urps_services = sum(annual_sling_count[specialty_group == "URPS (OB/GYN)"]),
                     total_services = sum(annual_sling_count), .groups = "drop")
  bsh <- tryCatch(fit_urps_share_binomial(ash, center_year = 2018), error = function(e) NULL)
  v$has_share_binom <- !is.null(bsh)
  if (v$has_share_binom) {
    v$share_binom_or   <- sprintf("%.3f (95%% CI %.3f-%.3f)", bsh$or_per_year, bsh$or_ci[1], bsh$or_ci[2])
    v$share_binom_pp   <- sprintf("%.2f", bsh$pp_per_year)
    v$share_binom_p    <- fmt_p(bsh$p_value)
    v$share_binom_2013 <- sprintf("%.1f", bsh$fitted_2013)
    v$share_binom_2023 <- sprintf("%.1f", bsh$fitted_2023)
  }

  # ── Classification bounds (Table 4 + prose) ────────────────────────────────
  share_trend <- function(pvx, grp_expr) {
    yy <- pvx %>% dplyr::group_by(.data[[year_col]]) %>%
      dplyr::summarise(tot = sum(annual_sling_count),
                       s = 100 * sum(annual_sling_count[grp_expr(specialty_group)]) / tot, .groups="drop")
    mm <- stats::lm(s ~ yy[[year_col]], yy)
    list(s13 = yy$s[which.min(yy[[year_col]])], s23 = yy$s[which.max(yy[[year_col]])],
         slope = stats::coef(mm)[2], p = summary(mm)$coefficients[2,4])
  }
  # Classification-scenario sensitivity is inherently about the aggregate URPS
  # certification-timing question, so it uses combined all-pathway URPS.
  is_urps <- sg_is_urps
  is_gyn  <- function(x) sg_is_urps(x) | x %in% c("MIGS","General OB/GYN")
  # fixed combined-URPS + gyn-trained (approx gyn = URPS+MIGS+GenOB under fixed)
  fu <- share_trend(pv, is_urps); fg <- share_trend(pv, is_gyn)
  v$fixed_urps_s13 <- round(fu$s13,1); v$fixed_urps_s23 <- round(fu$s23,1); v$fixed_urps_slope <- round(fu$slope,2)
  # gyn-trained (ABOG only) share uses subspecialty pathway
  gy <- gyn_trained_annual_share(pv, year_col) %>% dplyr::rename(s = pct_gyn)
  mgy <- stats::lm(gy$s ~ gy[[year_col]], gy)
  v$gyn_fixed_s13 <- round(gy$s[which.min(gy[[year_col]])],1); v$gyn_fixed_s23 <- round(gy$s[which.max(gy[[year_col]])],1)
  v$gyn_fixed_slope <- round(stats::coef(mgy)[2],2)
  v$gyn_fixed_p <- fmt_p(summary(mgy)$coefficients[2,4]); v$fixed_urps_p <- fmt_p(fu$p)
  # cert-gated time-varying
  base <- analyze_midurethral_sling_patterns(pc, year_col = year_col, abog_npi_csv = NULL,
             urps_urology_npi_csv = NULL, exclude_years = exclude_years, verbose = FALSE)$provider_volume %>%
    dplyr::mutate(specialty_group = ifelse(specialty_group == "OB/GYN", "General OB/GYN", specialty_group))
  cw <- readr::read_csv(certyear_csv, show_col_types = FALSE) %>% dplyr::mutate(npi = as.character(npi))
  tv <- assign_time_varying_certgated(base, year_col, cw) %>%
    dplyr::mutate(specialty_group = ifelse(Rndrng_NPI %in% abu & specialty_group != "MIGS", "URPS", specialty_group))
  # Apply cert-gated labels onto the FIXED cohort so both bounds share the same
  # denominator. The no-ABOG base drops "Other" providers that the primary
  # analysis reassigns to Urology; without this join the cert-gated denominator
  # is ~16,000 procedures smaller, spuriously inflating the cert-gated share.
  tv_labels <- tv %>% dplyr::select(Rndrng_NPI, dplyr::all_of(year_col), .cg = specialty_group)
  pvcg <- pv %>% dplyr::left_join(tv_labels, by = c("Rndrng_NPI", year_col)) %>%
    dplyr::mutate(specialty_group = dplyr::coalesce(.cg, specialty_group)) %>%
    dplyr::select(-.cg)
  cu <- share_trend(pvcg, is_urps); cgn <- share_trend(pvcg, is_gyn)
  v$ct_urps_s13 <- round(cu$s13,1); v$ct_urps_s23 <- round(cu$s23,1); v$ct_urps_slope <- round(cu$slope,2)
  v$ct_gyn_slope <- round(cgn$slope,2)
  v$ct_urps_p <- fmt_p(cu$p); v$ct_gyn_p <- fmt_p(cgn$p)
  # modal + ever URPS slopes (with p-values from the same scheme regressions).
  # The scheme functions define URPS as the single "URPS" group, so collapse the
  # two pathways first (the scheme sensitivity is about combined URPS).
  pv_comb <- pv %>% dplyr::mutate(
    specialty_group = ifelse(grepl("^URPS", specialty_group), "URPS", specialty_group))
  su_slope <- function(scheme) {
    st <- summarise_scheme(assign_specialty_scheme(pv_comb, scheme), year_col, scheme)$trends
    list(slope = round(st$urps_slope_pp_yr, 2), p = fmt_p(st$urps_p))
  }
  msl <- su_slope("modal"); esl <- su_slope("ever_urps_migs")
  v$modal_urps_slope <- msl$slope; v$modal_urps_p <- msl$p
  v$ever_urps_slope  <- esl$slope; v$ever_urps_p  <- esl$p
  bold_p <- function(p) sprintf("**%s**", p)
  tab$t4 <- data.frame(
    Analysis = c("Fixed membership: OB/GYN-based share (ABOG-URPS + MIGS + Gen OB/GYN)",
                 "Fixed membership: all-pathway URPS share",
                 "Modal: URPS share",
                 "Ever-URPS/MIGS: URPS share",
                 "**Certification-gated: URPS share (time-varying)**",
                 "Certification-gated: OB/GYN-based share (time-varying)"),
    `2013 -> 2023` = c(sprintf("%.1f%% → %.1f%%", v$gyn_fixed_s13, v$gyn_fixed_s23),
                       sprintf("%.1f%% → %.1f%%", v$fixed_urps_s13, v$fixed_urps_s23),
                       "n/a", "n/a",
                       sprintf("**%.1f%% → %.1f%%**", v$ct_urps_s13, v$ct_urps_s23), "n/a"),
    `Slope (pp/year)` = c(sprintf("%.2f", v$gyn_fixed_slope), sprintf("%.2f", v$fixed_urps_slope),
                          sprintf("%.2f", v$modal_urps_slope), sprintf("%.2f", v$ever_urps_slope),
                          sprintf("**%.2f**", v$ct_urps_slope), sprintf("%.2f", v$ct_gyn_slope)),
    `p-value` = c(v$gyn_fixed_p, v$fixed_urps_p, v$modal_urps_p, v$ever_urps_p,
                  bold_p(v$ct_urps_p), v$ct_gyn_p),
    check.names = FALSE)

  # ── Workforce (Table 5) and Geography — extracted sections (#5) ─────────────
  wfv <- compute_workforce_values(pv, ac, year_col)
  v <- utils::modifyList(v, wfv$v); tab$t5 <- wfv$t5
  v <- utils::modifyList(v, compute_geography_values(pv, pc, year_col))

  list(v = v, tab = tab, meta = list(
    generated_from = basename(puf_classified_path),
    n_values = length(v)))
}
