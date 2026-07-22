# =============================================================================
# volume_models.R
#
# Repeated-measures models for annual physician sling volume.
#
# The descriptive Kruskal-Wallis / pairwise Wilcoxon tests in
# build_focal_stats_table() operate on provider-YEAR rows, which are NOT
# independent — each physician (NPI) contributes up to 11 observations. This
# file provides the inferential alternatives:
#
#   fit_volume_nb_mixed()        negative-binomial mixed-effects model of the
#                                annual count with a random intercept per NPI;
#                                fixed effects for specialty, calendar year,
#                                specialty x year, and a 2020 (COVID) indicator.
#                                Reports adjusted rate ratios with 95% CIs.
#   per_physician_volume()       collapse to one row per NPI (median annual
#                                volume) — restores independence.
#   test_per_physician_volume()  Kruskal-Wallis + pairwise Wilcoxon on the
#                                one-value-per-physician summary (secondary).
#
# glmmTMB is an optional dependency; fit_volume_nb_mixed() returns NULL with a
# message if it is not installed, so the rest of the pipeline still runs.
#
# Authors: Tyler Muffly, MD
# =============================================================================

#' @noRd
#' Fit a negative-binomial mixed-effects model of annual sling volume.
#'
#' @param provider_volume_data one row per NPI-year with Rndrng_NPI,
#'   specialty_group, annual_sling_count and the year column.
#' @param year_col name of the calendar-year column.
#' @param reference_specialty factor reference level for specialty_group
#'   (rate ratios are expressed relative to it). Default "URPS".
#' @param exclude_2020 drop calendar year 2020 (COVID) as a sensitivity.
#' @return list(model, terms) where `terms` is a tidy tibble with rate_ratio,
#'   ci_low, ci_high, p_value, p_formatted; or NULL if glmmTMB is unavailable
#'   or the model fails to converge.
fit_volume_nb_mixed <- function(
    provider_volume_data,
    year_col            = "puf_year",
    reference_specialty = "URPS",
    exclude_2020        = FALSE,
    center_year         = 2018,
    verbose             = TRUE
) {
  if (!requireNamespace("glmmTMB", quietly = TRUE) ||
      !requireNamespace("broom.mixed", quietly = TRUE)) {
    message("[volume_models] glmmTMB/broom.mixed not available — skipping NB mixed model.")
    return(NULL)
  }
  stopifnot(all(
    c("Rndrng_NPI", "specialty_group", "annual_sling_count", year_col) %in%
      names(provider_volume_data)
  ))

  dat <- provider_volume_data
  if (isTRUE(exclude_2020)) {
    dat <- dat[dat[[year_col]] != 2020, , drop = FALSE]
  }

  # Center year (default 2018, mid-study) so the specialty main effects are the
  # rate ratios at mid-study rather than at an endpoint, and the year_c
  # coefficient is the per-year trend for the reference specialty.
  ctr <- if (is.null(center_year)) min(dat[[year_col]], na.rm = TRUE) else center_year
  dat$year_c   <- dat[[year_col]] - ctr
  dat$covid_2020 <- as.integer(dat[[year_col]] == 2020)
  dat$specialty_group <- stats::relevel(
    factor(dat$specialty_group), ref = reference_specialty
  )
  dat$Rndrng_NPI <- factor(dat$Rndrng_NPI)

  # A 2020 main effect is dropped automatically when exclude_2020 removes the
  # year (the column is all zero); build the formula accordingly.
  rhs <- if (isTRUE(exclude_2020)) {
    "specialty_group * year_c + (1 | Rndrng_NPI)"
  } else {
    "specialty_group * year_c + covid_2020 + (1 | Rndrng_NPI)"
  }
  form <- stats::as.formula(paste("annual_sling_count ~", rhs))

  model <- tryCatch(
    glmmTMB::glmmTMB(form, data = dat, family = glmmTMB::nbinom2),
    error = function(e) {
      message("[volume_models] NB mixed model failed: ", conditionMessage(e))
      NULL
    }
  )
  if (is.null(model)) return(NULL)

  terms <- broom.mixed::tidy(
    model, effects = "fixed", conf.int = TRUE, exponentiate = TRUE
  ) |>
    dplyr::transmute(
      term,
      rate_ratio = estimate,
      ci_low     = conf.low,
      ci_high    = conf.high,
      p_value    = p.value,
      p_formatted = dplyr::case_when(
        is.na(p.value)  ~ "NA",
        p.value < 0.001 ~ "<0.001",
        p.value < 0.01  ~ sprintf("%.3f", p.value),
        TRUE            ~ sprintf("%.2f", p.value)
      )
    )

  if (isTRUE(verbose)) {
    message(glue::glue(
      "[volume_models] NB mixed model: {nrow(dat)} physician-year rows, ",
      "{dplyr::n_distinct(dat$Rndrng_NPI)} NPIs, ref = {reference_specialty}",
      "{if (exclude_2020) ', 2020 excluded' else ''}."
    ))
  }
  list(model = model, terms = terms)
}

#' @noRd
#' Fit a Poisson GEE of annual sling volume with clustering by NPI.
#'
#' The population-averaged alternative to the NB mixed model (the user's second
#' named approach). An exchangeable working correlation with the NPI as the
#' cluster id, plus robust (sandwich) standard errors, accounts for the
#' within-physician correlation of repeated annual counts. Overdispersion is
#' handled by the robust SEs, so a Poisson working variance is appropriate.
#' Reports adjusted rate ratios with 95% CIs — no OpenMP/TMB dependency, so it
#' runs where glmmTMB cannot.
#'
#' @return list(model, terms) or NULL if geepack is unavailable.
fit_volume_gee <- function(
    provider_volume_data,
    year_col            = "puf_year",
    reference_specialty = "URPS",
    exclude_2020        = FALSE,
    corstr              = "exchangeable",
    center_year         = 2018,
    verbose             = TRUE
) {
  if (!requireNamespace("geepack", quietly = TRUE)) {
    message("[volume_models] geepack not installed — skipping GEE model.")
    return(NULL)
  }
  stopifnot(all(
    c("Rndrng_NPI", "specialty_group", "annual_sling_count", year_col) %in%
      names(provider_volume_data)
  ))

  dat <- provider_volume_data
  if (isTRUE(exclude_2020)) {
    dat <- dat[dat[[year_col]] != 2020, , drop = FALSE]
  }
  ctr <- if (is.null(center_year)) min(dat[[year_col]], na.rm = TRUE) else center_year
  dat$year_c         <- dat[[year_col]] - ctr
  dat$covid_2020     <- as.integer(dat[[year_col]] == 2020)
  dat$specialty_group <- stats::relevel(
    factor(dat$specialty_group), ref = reference_specialty
  )
  dat$Rndrng_NPI <- factor(dat$Rndrng_NPI)
  # geeglm requires clusters to be contiguous — order by the id.
  dat <- dat[order(dat$Rndrng_NPI), , drop = FALSE]

  rhs <- if (isTRUE(exclude_2020)) {
    "specialty_group * year_c"
  } else {
    "specialty_group * year_c + covid_2020"
  }
  form <- stats::as.formula(paste("annual_sling_count ~", rhs))

  model <- tryCatch(
    geepack::geeglm(
      form, id = Rndrng_NPI, data = dat,
      family = stats::poisson(link = "log"), corstr = corstr
    ),
    error = function(e) {
      message("[volume_models] GEE failed: ", conditionMessage(e)); NULL
    }
  )
  if (is.null(model)) return(NULL)

  co <- summary(model)$coefficients   # Estimate, Std.err, Wald, Pr(>|W|)
  terms <- tibble::tibble(
    term        = rownames(co),
    rate_ratio  = exp(co$Estimate),
    ci_low      = exp(co$Estimate - stats::qnorm(0.975) * co$Std.err),
    ci_high     = exp(co$Estimate + stats::qnorm(0.975) * co$Std.err),
    p_value     = co[["Pr(>|W|)"]],
    p_formatted = dplyr::case_when(
      is.na(co[["Pr(>|W|)"]])  ~ "NA",
      co[["Pr(>|W|)"]] < 0.001 ~ "<0.001",
      co[["Pr(>|W|)"]] < 0.01  ~ sprintf("%.3f", co[["Pr(>|W|)"]]),
      TRUE                     ~ sprintf("%.2f", co[["Pr(>|W|)"]])
    )
  )

  if (isTRUE(verbose)) {
    message(glue::glue(
      "[volume_models] Poisson GEE ({corstr}): {nrow(dat)} physician-year rows, ",
      "{dplyr::n_distinct(dat$Rndrng_NPI)} NPI clusters, ref = {reference_specialty}",
      "{if (exclude_2020) ', 2020 excluded' else ''}."
    ))
  }
  list(model = model, terms = terms)
}

#' @noRd
#' Collapse provider-years to one row per physician (median annual volume).
#' Restores independence for a secondary cross-physician comparison.
per_physician_volume <- function(provider_volume_data) {
  provider_volume_data |>
    dplyr::group_by(Rndrng_NPI, specialty_group) |>
    dplyr::summarise(
      n_years              = dplyr::n(),
      median_annual_volume = stats::median(annual_sling_count, na.rm = TRUE),
      .groups = "drop"
    )
}

#' @noRd
#' Secondary analysis: Kruskal-Wallis + pairwise Wilcoxon on ONE value per
#' physician (median annual volume), so each NPI contributes a single
#' observation. Returns a tidy tibble comparable to build_focal_stats_table().
test_per_physician_volume <- function(
    provider_volume_data,
    p_adjust_method = "bonferroni"
) {
  pp <- per_physician_volume(provider_volume_data)

  kruskal <- stats::kruskal.test(median_annual_volume ~ specialty_group, data = pp) |>
    broom::tidy() |>
    dplyr::transmute(
      test        = "Kruskal-Wallis: per-physician median volume across specialties",
      statistic, df = parameter, p_value = p.value,
      p_formatted = dplyr::case_when(
        p.value < 0.001 ~ "<0.001",
        p.value < 0.01  ~ sprintf("%.3f", p.value),
        TRUE            ~ sprintf("%.2f", p.value)
      )
    )

  pw <- tryCatch(
    stats::pairwise.wilcox.test(
      pp$median_annual_volume, pp$specialty_group,
      p.adjust.method = p_adjust_method, exact = FALSE
    ) |>
      broom::tidy() |>
      dplyr::transmute(
        test        = glue::glue("Wilcoxon (per-physician, {p_adjust_method}): {group1} vs {group2}"),
        statistic   = NA_real_, df = NA_real_, p_value = p.value,
        p_formatted = dplyr::case_when(
          is.na(p.value)  ~ "NA",
          p.value < 0.001 ~ "<0.001",
          p.value < 0.01  ~ sprintf("%.3f", p.value),
          TRUE            ~ sprintf("%.2f", p.value)
        )
      ),
    error = function(e) NULL
  )

  dplyr::bind_rows(kruskal, pw)
}

#' @noRd
#' Specialty-specific annual volume slopes (marginal contrasts) from a fitted
#' GEE or NB model that includes specialty_group * year_c.
#'
#' With an interaction, the year_c main effect is the slope for the reference
#' specialty only; each non-reference specialty's slope is the sum of the
#' year_c coefficient and its specialty:year_c interaction. This function forms
#' those linear combinations and their standard errors from the model
#' variance-covariance matrix, returning per-specialty annual rate ratios with
#' 95% CIs (reviewer #4: report specialty-specific slopes / marginal contrasts,
#' not just the reference-year main effects).
#'
#' @param model a fitted geeglm (or glmmTMB) object.
#' @param reference_specialty the releveled reference (its slope is year_c).
#' @return tibble(specialty, slope_rr, ci_low, ci_high, p_value, p_formatted).
specialty_year_slopes <- function(model, reference_specialty = "URPS") {
  b  <- stats::coef(model)
  V  <- stats::vcov(model)
  if (inherits(model, "glmmTMB")) { b <- b$cond; V <- V$cond }
  nm <- names(b)
  year_term <- "year_c"
  if (!year_term %in% nm) return(NULL)
  # specialty levels appear as specialty_group<Level> main effects
  spec_main <- grep("^specialty_group", nm, value = TRUE)
  spec_main <- spec_main[!grepl(":", spec_main)]
  levels_nonref <- sub("^specialty_group", "", spec_main)
  rows <- list()
  add_row <- function(label, coefs) {
    L <- rep(0, length(b)); names(L) <- nm; L[coefs] <- 1
    est <- sum(L * b)
    se  <- sqrt(as.numeric(t(L) %*% V %*% L))
    z   <- est / se
    p   <- 2 * stats::pnorm(-abs(z))
    tibble::tibble(
      specialty = label, slope_rr = exp(est),
      ci_low = exp(est - stats::qnorm(0.975) * se),
      ci_high = exp(est + stats::qnorm(0.975) * se),
      p_value = p,
      p_formatted = dplyr::case_when(
        p < 0.001 ~ "<0.001", p < 0.01 ~ sprintf("%.3f", p), TRUE ~ sprintf("%.2f", p)))
  }
  rows[[reference_specialty]] <- add_row(reference_specialty, year_term)
  for (lv in levels_nonref) {
    inter <- paste0("specialty_group", lv, ":", year_term)
    coefs <- if (inter %in% nm) c(year_term, inter) else year_term
    rows[[lv]] <- add_row(lv, coefs)
  }
  dplyr::bind_rows(rows)
}

#' @noRd
#' Model the annual URPS share of services with a quasibinomial GLM on year,
#' respecting the compositional nature of shares (reviewer #4: the 11 annual
#' percentages are not independent OLS points; model URPS services out of all
#' annual services). Returns the per-year change on the odds and percentage-point
#' scales with a 95% CI, plus the fitted 2013 and 2023 shares.
#'
#' @param annual_share data.frame with year, urps_services, total_services.
#' @param center_year year at which to evaluate the marginal pp/year slope.
fit_urps_share_binomial <- function(annual_share, center_year = 2018) {
  stopifnot(all(c("year", "urps_services", "total_services") %in% names(annual_share)))
  d <- annual_share
  d$year_c <- d$year - center_year
  d$other  <- d$total_services - d$urps_services
  m <- stats::glm(cbind(urps_services, other) ~ year_c, data = d,
                  family = stats::quasibinomial())
  co <- summary(m)$coefficients
  b_year <- co["year_c", "Estimate"]; se_year <- co["year_c", "Std. Error"]
  p_year <- co["year_c", "Pr(>|t|)"]
  # marginal pp/year at the mean fitted probability (approx dp/dyear = p(1-p)*b)
  phat <- stats::predict(m, newdata = data.frame(year_c = 0), type = "response")
  pp_per_year <- 100 * phat * (1 - phat) * b_year
  fit_at <- function(y) 100 * stats::predict(m, newdata = data.frame(year_c = y - center_year),
                                             type = "response")
  list(
    model = m,
    or_per_year = exp(b_year),
    or_ci = exp(b_year + c(-1, 1) * stats::qnorm(0.975) * se_year),
    pp_per_year = pp_per_year,
    p_value = p_year,
    fitted_2013 = as.numeric(fit_at(2013)),
    fitted_2023 = as.numeric(fit_at(2023))
  )
}
