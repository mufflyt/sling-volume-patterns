# Publication-ready figures for the Medicare sling-for-SUI manuscript
#
# Required input: one row per physician-year with these columns:
#   npi
#   year
#   procedures
#   specialty_fixed
#   specialty_cert_gated
#   state_abbr
#
# specialty_fixed and specialty_cert_gated may contain:
#   URPS
#   Urology or Urology (non-URPS)
#   General OB/GYN
#   MIGS
#
# The functions:
#   * include all years by default (pass excluded_years to drop any);
#   * compute entrant and exit flags using two observable years;
#   * append a timestamp to every saved file;
#   * log inputs, transformations, and exact saved paths.

check_sling_figure_packages <- function() {
  required_packages <- base::c(
    "dplyr",
    "tidyr",
    "tibble",
    "stringr",
    "ggplot2",
    "ggdist",
    "patchwork",
    "scales",
    "sf",
    "tigris"
  )

  missing_packages <- required_packages[
    !base::vapply(
      required_packages,
      base::requireNamespace,
      base::logical(1),
      quietly = TRUE
    )
  ]

  if (base::length(missing_packages) > 0L) {
    package_text <- base::paste(
      base::sprintf('"%s"', missing_packages),
      collapse = ", "
    )

    base::stop(
      base::paste0(
        "Install missing packages in R with:\n",
        "install.packages(c(",
        package_text,
        "))"
      ),
      call. = FALSE
    )
  }

  base::message(
    "Package check complete: all required packages are available."
  )

  base::invisible(required_packages)
}


as_analysis_tbl <- function(source_tbl) {
  source_tbl <- tibble::as_tibble(source_tbl)

  if (base::requireNamespace("duckplyr", quietly = TRUE)) {
    base::message(
      "Using duckplyr for supported local transformations."
    )

    return(duckplyr::as_duckplyr_tibble(source_tbl))
  }

  base::message(
    "duckplyr is unavailable; using a standard tibble."
  )

  source_tbl
}


normalize_sling_specialty <- function(specialty_vector) {
  specialty_text <- specialty_vector |>
    base::as.character() |>
    stringr::str_squish() |>
    stringr::str_to_lower()

  dplyr::case_when(
    base::is.na(specialty_text) ~ NA_character_,
    stringr::str_detect(
      specialty_text,
      "urps|fpmrs|urogynec"
    ) ~ "URPS",
    stringr::str_detect(
      specialty_text,
      "migs|minimally invasive"
    ) ~ "MIGS",
    stringr::str_detect(
      specialty_text,
      "urolog"
    ) ~ "Urology",
    stringr::str_detect(
      specialty_text,
      "general.*ob|ob.?gyn|obstetric"
    ) ~ "General OB/GYN",
    TRUE ~ stringr::str_to_title(specialty_text)
  )
}


validate_sling_input <- function(physician_year_tbl) {
  required_columns <- base::c(
    "npi",
    "year",
    "procedures",
    "specialty_fixed",
    "specialty_cert_gated",
    "state_abbr"
  )

  missing_columns <- base::setdiff(
    required_columns,
    base::names(physician_year_tbl)
  )

  if (base::length(missing_columns) > 0L) {
    base::stop(
      base::paste0(
        "Missing required columns: ",
        base::paste(missing_columns, collapse = ", ")
      ),
      call. = FALSE
    )
  }

  duplicate_tbl <- physician_year_tbl |>
    dplyr::count(.data$npi, .data$year, name = "row_count") |>
    dplyr::filter(.data$row_count > 1L) |>
    tibble::as_tibble()

  if (base::nrow(duplicate_tbl) > 0L) {
    base::stop(
      base::paste0(
        "Input must contain one row per physician-year. ",
        "Aggregate duplicate NPI-year rows before plotting."
      ),
      call. = FALSE
    )
  }

  invalid_count <- physician_year_tbl |>
    dplyr::filter(
      base::is.na(.data$procedures) |
        .data$procedures < 0
    ) |>
    dplyr::summarise(
      invalid_count = dplyr::n()
    ) |>
    dplyr::pull(.data$invalid_count)

  if (invalid_count > 0L) {
    base::stop(
      "procedures must be nonmissing and nonnegative.",
      call. = FALSE
    )
  }

  base::message(
    "Input validation complete: ",
    scales::comma(base::nrow(physician_year_tbl)),
    " physician-year rows."
  )

  base::invisible(TRUE)
}


prepare_sling_figure_input <- function(
    physician_year_tbl,
    excluded_years = integer(0)) {
  base::message("Preparing the physician-year analytic table.")

  physician_year_tbl <- as_analysis_tbl(physician_year_tbl)

  validate_sling_input(physician_year_tbl)

  prepared_tbl <- physician_year_tbl |>
    dplyr::transmute(
      npi = base::as.character(.data$npi),
      year = base::as.integer(.data$year),
      procedures = base::as.numeric(.data$procedures),
      specialty_fixed = normalize_sling_specialty(
        .data$specialty_fixed
      ),
      specialty_cert_gated = normalize_sling_specialty(
        .data$specialty_cert_gated
      ),
      state_abbr = stringr::str_to_upper(
        stringr::str_squish(
          base::as.character(.data$state_abbr)
        )
      )
    ) |>
    dplyr::filter(
      !.data$year %in% base::as.integer(excluded_years)
    ) |>
    dplyr::filter(
      !base::is.na(.data$npi),
      !base::is.na(.data$year),
      !base::is.na(.data$specialty_fixed)
    ) |>
    dplyr::mutate(
      specialty_fixed = base::factor(
        .data$specialty_fixed,
        levels = base::c(
          "URPS",
          "Urology",
          "General OB/GYN",
          "MIGS"
        )
      ),
      specialty_cert_gated = base::factor(
        .data$specialty_cert_gated,
        levels = base::c(
          "URPS",
          "Urology",
          "General OB/GYN",
          "MIGS"
        )
      )
    ) |>
    dplyr::arrange(.data$year, .data$npi) |>
    tibble::as_tibble()

  base::message(
    "Excluded years: ",
    base::paste(excluded_years, collapse = ", "),
    "."
  )

  base::message(
    "Prepared ",
    scales::comma(base::nrow(prepared_tbl)),
    " rows spanning ",
    base::min(prepared_tbl$year),
    " to ",
    base::max(prepared_tbl$year),
    "."
  )

  prepared_tbl
}


add_observable_workforce_flags <- function(prepared_tbl) {
  base::message(
    "Computing entrant and exit flags with a two-year washout."
  )

  year_index_tbl <- prepared_tbl |>
    dplyr::distinct(.data$year) |>
    dplyr::arrange(.data$year) |>
    dplyr::mutate(
      year_index = dplyr::row_number()
    )

  indexed_tbl <- prepared_tbl |>
    dplyr::left_join(
      year_index_tbl,
      by = "year"
    )

  presence_tbl <- indexed_tbl |>
    dplyr::distinct(.data$npi, .data$year_index)

  prior_one_tbl <- presence_tbl |>
    dplyr::transmute(
      npi = .data$npi,
      year_index = .data$year_index + 1L,
      has_prior_one = TRUE
    )

  prior_two_tbl <- presence_tbl |>
    dplyr::transmute(
      npi = .data$npi,
      year_index = .data$year_index + 2L,
      has_prior_two = TRUE
    )

  future_one_tbl <- presence_tbl |>
    dplyr::transmute(
      npi = .data$npi,
      year_index = .data$year_index - 1L,
      has_future_one = TRUE
    )

  future_two_tbl <- presence_tbl |>
    dplyr::transmute(
      npi = .data$npi,
      year_index = .data$year_index - 2L,
      has_future_two = TRUE
    )

  max_year_index <- base::max(year_index_tbl$year_index)

  flagged_tbl <- indexed_tbl |>
    dplyr::left_join(
      prior_one_tbl,
      by = base::c("npi", "year_index")
    ) |>
    dplyr::left_join(
      prior_two_tbl,
      by = base::c("npi", "year_index")
    ) |>
    dplyr::left_join(
      future_one_tbl,
      by = base::c("npi", "year_index")
    ) |>
    dplyr::left_join(
      future_two_tbl,
      by = base::c("npi", "year_index")
    ) |>
    dplyr::mutate(
      has_prior_one = dplyr::coalesce(
        .data$has_prior_one,
        FALSE
      ),
      has_prior_two = dplyr::coalesce(
        .data$has_prior_two,
        FALSE
      ),
      has_future_one = dplyr::coalesce(
        .data$has_future_one,
        FALSE
      ),
      has_future_two = dplyr::coalesce(
        .data$has_future_two,
        FALSE
      ),
      entrant = dplyr::if_else(
        .data$year_index <= 2L,
        NA,
        !.data$has_prior_one & !.data$has_prior_two
      ),
      exiting = dplyr::if_else(
        .data$year_index > max_year_index - 2L,
        NA,
        !.data$has_future_one & !.data$has_future_two
      )
    ) |>
    dplyr::select(
      -.data$has_prior_one,
      -.data$has_prior_two,
      -.data$has_future_one,
      -.data$has_future_two
    ) |>
    tibble::as_tibble()

  base::message(
    "Workforce flags computed for ",
    scales::comma(
      dplyr::n_distinct(flagged_tbl$npi)
    ),
    " unique physicians."
  )

  flagged_tbl
}


format_manuscript_p <- function(p_value) {
  if (base::is.na(p_value)) {
    return("p = NA")
  }

  if (p_value < 0.001) {
    return("p < 0.001")
  }

  base::paste0(
    "p = ",
    base::formatC(
      p_value,
      format = "f",
      digits = 3
    )
  )
}


make_count_trend_sentence <- function(
    annual_tbl,
    value_column,
    metric_label) {
  ordered_tbl <- annual_tbl |>
    dplyr::arrange(.data$year) |>
    tibble::as_tibble()

  trend_formula <- stats::as.formula(
    base::paste(value_column, "~ year")
  )

  trend_fit <- stats::lm(
    formula = trend_formula,
    data = ordered_tbl
  )

  slope_value <- stats::coef(trend_fit)[["year"]]

  coefficient_tbl <- stats::coef(
    base::summary(trend_fit)
  )

  p_value <- coefficient_tbl["year", "Pr(>|t|)"]

  first_value <- ordered_tbl[[value_column]][1L]
  last_value <- ordered_tbl[[value_column]][
    base::nrow(ordered_tbl)
  ]

  direction_text <- dplyr::case_when(
    slope_value > 0 ~ "increased",
    slope_value < 0 ~ "decreased",
    TRUE ~ "did not change"
  )

  base::paste0(
    "From ",
    base::min(ordered_tbl$year),
    " to ",
    base::max(ordered_tbl$year),
    ", ",
    metric_label,
    " ",
    direction_text,
    " from ",
    scales::comma(first_value),
    " to ",
    scales::comma(last_value),
    " (",
    format_manuscript_p(p_value),
    ")."
  )
}


make_share_trend_sentence <- function(
    annual_share_tbl,
    scheme_name = "Fixed membership") {
  target_tbl <- annual_share_tbl |>
    dplyr::filter(
      .data$scheme == scheme_name
    ) |>
    dplyr::arrange(.data$year) |>
    tibble::as_tibble()

  trend_fit <- stats::lm(
    share_percent ~ year,
    data = target_tbl
  )

  coefficient_tbl <- stats::coef(
    base::summary(trend_fit)
  )

  slope_value <- stats::coef(trend_fit)[["year"]]
  p_value <- coefficient_tbl["year", "Pr(>|t|)"]

  first_share <- target_tbl$share_percent[1L]
  last_share <- target_tbl$share_percent[
    base::nrow(target_tbl)
  ]

  direction_text <- dplyr::case_when(
    slope_value > 0 ~ "increased",
    slope_value < 0 ~ "decreased",
    TRUE ~ "did not change"
  )

  base::paste0(
    "URPS share ",
    direction_text,
    " from ",
    scales::number(first_share, accuracy = 0.1),
    "% in ",
    base::min(target_tbl$year),
    " to ",
    scales::number(last_share, accuracy = 0.1),
    "% in ",
    base::max(target_tbl$year),
    " (",
    scales::number(
      base::abs(slope_value),
      accuracy = 0.01
    ),
    " percentage points/year; ",
    format_manuscript_p(p_value),
    ")."
  )
}


sling_specialty_palette <- function() {
  base::c(
    "URPS" = "#0072B2",
    "Urology" = "#D55E00",
    "General OB/GYN" = "#009E73",
    "MIGS" = "#CC79A7"
  )
}


sling_figure_theme <- function(base_size = 11) {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      plot.title.position = "plot",
      plot.caption.position = "plot",
      plot.title = ggplot2::element_text(
        face = "bold",
        size = base_size + 2
      ),
      plot.subtitle = ggplot2::element_text(
        size = base_size
      ),
      plot.caption = ggplot2::element_text(
        size = base_size - 2,
        hjust = 0
      ),
      panel.grid.minor = ggplot2::element_blank(),
      legend.position = "bottom",
      legend.title = ggplot2::element_blank(),
      axis.title = ggplot2::element_text(
        face = "bold"
      ),
      strip.text = ggplot2::element_text(
        face = "bold"
      )
    )
}


save_sling_plot <- function(
    plot_object,
    file_stem,
    save_dir,
    run_timestamp,
    width,
    height,
    dpi = 600) {
  base::dir.create(
    save_dir,
    recursive = TRUE,
    showWarnings = FALSE
  )

  saved_path <- base::file.path(
    save_dir,
    base::paste0(
      file_stem,
      "_",
      run_timestamp,
      ".png"
    )
  )

  ggplot2::ggsave(
    filename = saved_path,
    plot = plot_object,
    width = width,
    height = height,
    units = "in",
    dpi = dpi,
    bg = "white"
  )

  exact_path <- base::normalizePath(
    saved_path,
    winslash = "/",
    mustWork = TRUE
  )

  base::message("Saved figure: ", exact_path)

  exact_path
}


figure_1_specialty_share <- function(
    prepared_tbl,
    save_dir,
    run_timestamp) {
  base::message(
    "Figure 1: calculating specialty shares and bounds."
  )

  fixed_share_tbl <- prepared_tbl |>
    dplyr::group_by(
      .data$year,
      specialty = .data$specialty_fixed
    ) |>
    dplyr::summarise(
      procedures = base::sum(.data$procedures),
      .groups = "drop"
    ) |>
    dplyr::group_by(.data$year) |>
    dplyr::mutate(
      share = .data$procedures /
        base::sum(.data$procedures)
    ) |>
    dplyr::ungroup() |>
    dplyr::filter(!base::is.na(.data$specialty)) |>
    tibble::as_tibble()

  fixed_urps_tbl <- fixed_share_tbl |>
    dplyr::filter(.data$specialty == "URPS") |>
    dplyr::transmute(
      year = .data$year,
      share = .data$share,
      share_percent = 100 * .data$share,
      scheme = "Fixed membership"
    )

  gated_urps_tbl <- prepared_tbl |>
    dplyr::group_by(
      .data$year,
      specialty = .data$specialty_cert_gated
    ) |>
    dplyr::summarise(
      procedures = base::sum(.data$procedures),
      .groups = "drop"
    ) |>
    dplyr::group_by(.data$year) |>
    dplyr::mutate(
      share = .data$procedures /
        base::sum(.data$procedures)
    ) |>
    dplyr::ungroup() |>
    dplyr::filter(.data$specialty == "URPS") |>
    dplyr::transmute(
      year = .data$year,
      share = .data$share,
      share_percent = 100 * .data$share,
      scheme = "Certification gated"
    )

  bound_tbl <- dplyr::bind_rows(
    fixed_urps_tbl,
    gated_urps_tbl
  ) |>
    tibble::as_tibble()

  trend_sentence <- make_share_trend_sentence(
    bound_tbl,
    scheme_name = "Fixed membership"
  )

  figure_plot <- ggplot2::ggplot(
    fixed_share_tbl,
    ggplot2::aes(
      x = .data$year,
      y = .data$share,
      fill = .data$specialty
    )
  ) +
    ggplot2::geom_area(
      position = "stack",
      alpha = 0.88
    ) +
    ggplot2::geom_line(
      data = bound_tbl,
      mapping = ggplot2::aes(
        x = .data$year,
        y = .data$share,
        linetype = .data$scheme
      ),
      inherit.aes = FALSE,
      linewidth = 1,
      color = "black"
    ) +
    ggplot2::geom_vline(
      xintercept = 2020,
      linetype = "dotted",
      linewidth = 0.5
    ) +
    ggplot2::scale_fill_manual(
      values = sling_specialty_palette(),
      drop = FALSE
    ) +
    ggplot2::scale_linetype_manual(
      values = base::c(
        "Fixed membership" = "solid",
        "Certification gated" = "longdash"
      )
    ) +
    ggplot2::scale_x_continuous(
      breaks = base::sort(
        base::unique(fixed_share_tbl$year)
      )
    ) +
    ggplot2::scale_y_continuous(
      labels = scales::label_percent(
        accuracy = 1
      ),
      limits = base::c(0, 1),
      expand = ggplot2::expansion(mult = base::c(0, 0))
    ) +
    ggplot2::labs(
      title = "URPS gained share of Medicare sling procedures",
      subtitle = trend_sentence,
      x = NULL,
      y = "Share of observed procedures",
      caption = base::paste0(
        "Areas use fixed membership. Black lines show the URPS ",
        "share under fixed and certification-gated schemes. ",
        "CMS suppresses provider-service cells with fewer than ",
        "11 beneficiaries."
      )
    ) +
    sling_figure_theme()

  saved_path <- save_sling_plot(
    plot_object = figure_plot,
    file_stem = "figure_1_specialty_share",
    save_dir = save_dir,
    run_timestamp = run_timestamp,
    width = 8.5,
    height = 5.5
  )

  base::list(
    plot = figure_plot,
    path = saved_path
  )
}


figure_2_workforce_and_volume <- function(
    prepared_tbl,
    save_dir,
    run_timestamp) {
  base::message(
    "Figure 2: calculating annual workforce and volume."
  )

  annual_specialty_tbl <- prepared_tbl |>
    dplyr::group_by(
      .data$year,
      specialty = .data$specialty_fixed
    ) |>
    dplyr::summarise(
      physicians = dplyr::n_distinct(.data$npi),
      procedures = base::sum(.data$procedures),
      .groups = "drop"
    ) |>
    tibble::as_tibble()

  annual_total_tbl <- prepared_tbl |>
    dplyr::group_by(.data$year) |>
    dplyr::summarise(
      physicians = dplyr::n_distinct(.data$npi),
      procedures = base::sum(.data$procedures),
      .groups = "drop"
    ) |>
    tibble::as_tibble()

  physician_sentence <- make_count_trend_sentence(
    annual_total_tbl,
    value_column = "physicians",
    metric_label = "the observable surgeon pool"
  )

  procedure_sentence <- make_count_trend_sentence(
    annual_total_tbl,
    value_column = "procedures",
    metric_label = "observed Medicare sling volume"
  )

  physician_plot <- ggplot2::ggplot(
    annual_specialty_tbl,
    ggplot2::aes(
      x = .data$year,
      y = .data$physicians,
      fill = .data$specialty
    )
  ) +
    ggplot2::geom_col(width = 0.82) +
    ggplot2::geom_line(
      data = annual_total_tbl,
      mapping = ggplot2::aes(
        x = .data$year,
        y = .data$physicians,
        group = 1
      ),
      inherit.aes = FALSE,
      linewidth = 0.8,
      color = "black"
    ) +
    ggplot2::geom_point(
      data = annual_total_tbl,
      mapping = ggplot2::aes(
        x = .data$year,
        y = .data$physicians
      ),
      inherit.aes = FALSE,
      size = 1.6,
      color = "black"
    ) +
    ggplot2::scale_fill_manual(
      values = sling_specialty_palette(),
      drop = FALSE
    ) +
    ggplot2::scale_x_continuous(
      breaks = base::sort(
        base::unique(annual_specialty_tbl$year)
      )
    ) +
    ggplot2::scale_y_continuous(
      labels = scales::label_comma(),
      expand = ggplot2::expansion(
        mult = base::c(0, 0.08)
      )
    ) +
    ggplot2::labs(
      title = "A. Observable surgeons",
      x = NULL,
      y = "Physicians"
    ) +
    sling_figure_theme()

  volume_plot <- ggplot2::ggplot(
    annual_specialty_tbl,
    ggplot2::aes(
      x = .data$year,
      y = .data$procedures,
      fill = .data$specialty
    )
  ) +
    ggplot2::geom_col(width = 0.82) +
    ggplot2::geom_line(
      data = annual_total_tbl,
      mapping = ggplot2::aes(
        x = .data$year,
        y = .data$procedures,
        group = 1
      ),
      inherit.aes = FALSE,
      linewidth = 0.8,
      color = "black"
    ) +
    ggplot2::geom_point(
      data = annual_total_tbl,
      mapping = ggplot2::aes(
        x = .data$year,
        y = .data$procedures
      ),
      inherit.aes = FALSE,
      size = 1.6,
      color = "black"
    ) +
    ggplot2::scale_fill_manual(
      values = sling_specialty_palette(),
      drop = FALSE
    ) +
    ggplot2::scale_x_continuous(
      breaks = base::sort(
        base::unique(annual_specialty_tbl$year)
      )
    ) +
    ggplot2::scale_y_continuous(
      labels = scales::label_comma(),
      expand = ggplot2::expansion(
        mult = base::c(0, 0.08)
      )
    ) +
    ggplot2::labs(
      title = "B. Observed procedures",
      x = "Calendar year",
      y = "Procedures"
    ) +
    sling_figure_theme()

  figure_plot <- patchwork::wrap_plots(
    physician_plot,
    volume_plot,
    ncol = 1,
    guides = "collect"
  ) +
    patchwork::plot_annotation(
      title = base::paste0(
        "The Medicare sling workforce and procedure pool contracted"
      ),
      subtitle = base::paste(
        physician_sentence,
        procedure_sentence
      ),
      caption = base::paste0(
        "Stacked bars show specialty composition; black lines show ",
        "annual totals. The dotted line marks 2020."
      )
    ) &
    ggplot2::theme(
      legend.position = "bottom"
    )

  saved_path <- save_sling_plot(
    plot_object = figure_plot,
    file_stem = "figure_2_workforce_and_volume",
    save_dir = save_dir,
    run_timestamp = run_timestamp,
    width = 8.5,
    height = 8
  )

  base::list(
    plot = figure_plot,
    path = saved_path
  )
}


figure_3_volume_raincloud <- function(
    prepared_tbl,
    save_dir,
    run_timestamp,
    reference_volume = 50) {
  base::message(
    "Figure 3: preparing physician-year volume distributions."
  )

  volume_summary_tbl <- prepared_tbl |>
    dplyr::group_by(
      specialty = .data$specialty_fixed
    ) |>
    dplyr::summarise(
      mean_volume = base::mean(.data$procedures),
      sd_volume = stats::sd(.data$procedures),
      median_volume = stats::median(.data$procedures),
      p25 = stats::quantile(
        .data$procedures,
        probs = 0.25,
        names = FALSE
      ),
      p75 = stats::quantile(
        .data$procedures,
        probs = 0.75,
        names = FALSE
      ),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      summary_label = base::paste0(
        "Mean ",
        scales::number(
          .data$mean_volume,
          accuracy = 0.1
        ),
        " (SD ",
        scales::number(
          .data$sd_volume,
          accuracy = 0.1
        ),
        "); median ",
        scales::number(
          .data$median_volume,
          accuracy = 0.1
        ),
        " (p25–p75, ",
        scales::number(
          .data$p25,
          accuracy = 0.1
        ),
        "–",
        scales::number(
          .data$p75,
          accuracy = 0.1
        ),
        ")"
      )
    ) |>
    tibble::as_tibble()

  base::message("Figure 3 specialty summaries:")
  base::message(
    base::paste(
      volume_summary_tbl$specialty,
      volume_summary_tbl$summary_label,
      sep = ": ",
      collapse = "\n"
    )
  )

  figure_plot <- ggplot2::ggplot(
    prepared_tbl,
    ggplot2::aes(
      x = .data$procedures,
      y = .data$specialty_fixed,
      fill = .data$specialty_fixed
    )
  ) +
    ggdist::stat_halfeye(
      adjust = 0.65,
      width = 0.72,
      justification = -0.20,
      .width = 0,
      point_colour = NA,
      alpha = 0.75
    ) +
    ggplot2::geom_boxplot(
      width = 0.16,
      outlier.shape = NA,
      alpha = 0.80
    ) +
    ggplot2::geom_jitter(
      mapping = ggplot2::aes(
        color = .data$specialty_fixed
      ),
      height = 0.10,
      width = 0,
      alpha = 0.14,
      size = 0.6,
      show.legend = FALSE
    ) +
    ggplot2::geom_vline(
      xintercept = reference_volume,
      linetype = "dashed",
      linewidth = 0.6
    ) +
    ggplot2::scale_fill_manual(
      values = sling_specialty_palette(),
      drop = FALSE
    ) +
    ggplot2::scale_color_manual(
      values = sling_specialty_palette(),
      drop = FALSE
    ) +
    ggplot2::scale_x_log10(
      labels = scales::label_comma()
    ) +
    ggplot2::labs(
      title = "Annual sling volume was highest among URPS physicians",
      subtitle = base::paste0(
        "Each point is one physician-year; the x-axis is logarithmic."
      ),
      x = "Observed annual Medicare sling procedures",
      y = NULL,
      caption = base::paste0(
        "The dashed line marks ",
        scales::comma(reference_volume),
        " procedures/year and can be removed by setting ",
        "reference_volume = NULL. The observable minimum is shaped ",
        "by CMS suppression of cells with fewer than 11 beneficiaries."
      )
    ) +
    sling_figure_theme()

  if (base::is.null(reference_volume)) {
    figure_plot <- ggplot2::ggplot(
      prepared_tbl,
      ggplot2::aes(
        x = .data$procedures,
        y = .data$specialty_fixed,
        fill = .data$specialty_fixed
      )
    ) +
      ggdist::stat_halfeye(
        adjust = 0.65,
        width = 0.72,
        justification = -0.20,
        .width = 0,
        point_colour = NA,
        alpha = 0.75
      ) +
      ggplot2::geom_boxplot(
        width = 0.16,
        outlier.shape = NA,
        alpha = 0.80
      ) +
      ggplot2::geom_jitter(
        mapping = ggplot2::aes(
          color = .data$specialty_fixed
        ),
        height = 0.10,
        width = 0,
        alpha = 0.14,
        size = 0.6,
        show.legend = FALSE
      ) +
      ggplot2::scale_fill_manual(
        values = sling_specialty_palette(),
        drop = FALSE
      ) +
      ggplot2::scale_color_manual(
        values = sling_specialty_palette(),
        drop = FALSE
      ) +
      ggplot2::scale_x_log10(
        labels = scales::label_comma()
      ) +
      ggplot2::labs(
        title = base::paste0(
          "Annual sling volume was highest among URPS physicians"
        ),
        subtitle = base::paste0(
          "Each point is one physician-year; ",
          "the x-axis is logarithmic."
        ),
        x = "Observed annual Medicare sling procedures",
        y = NULL,
        caption = base::paste0(
          "The observable minimum is shaped by CMS suppression of ",
          "cells with fewer than 11 beneficiaries."
        )
      ) +
      sling_figure_theme()
  }

  saved_path <- save_sling_plot(
    plot_object = figure_plot,
    file_stem = "figure_3_volume_raincloud",
    save_dir = save_dir,
    run_timestamp = run_timestamp,
    width = 8.5,
    height = 5.5
  )

  base::list(
    plot = figure_plot,
    path = saved_path,
    summary = volume_summary_tbl
  )
}


calculate_gini <- function(value_vector) {
  clean_vector <- value_vector[
    base::is.finite(value_vector) &
      !base::is.na(value_vector) &
      value_vector >= 0
  ]

  if (
    base::length(clean_vector) == 0L ||
      base::sum(clean_vector) == 0
  ) {
    return(NA_real_)
  }

  ordered_vector <- base::sort(clean_vector)
  vector_length <- base::length(ordered_vector)
  rank_vector <- base::seq_len(vector_length)

  2 * base::sum(rank_vector * ordered_vector) /
    (
      vector_length *
        base::sum(ordered_vector)
    ) -
    (vector_length + 1) / vector_length
}


calculate_top_share <- function(
    value_vector,
    top_fraction = 0.20) {
  clean_vector <- value_vector[
    base::is.finite(value_vector) &
      !base::is.na(value_vector) &
      value_vector >= 0
  ]

  if (
    base::length(clean_vector) == 0L ||
      base::sum(clean_vector) == 0
  ) {
    return(NA_real_)
  }

  top_count <- base::max(
    1L,
    base::ceiling(
      top_fraction * base::length(clean_vector)
    )
  )

  ordered_vector <- base::sort(
    clean_vector,
    decreasing = TRUE
  )

  base::sum(
    ordered_vector[base::seq_len(top_count)]
  ) /
    base::sum(ordered_vector)
}


figure_4_lorenz_curves <- function(
    prepared_tbl,
    save_dir,
    run_timestamp,
    include_migs = FALSE) {
  base::message(
    "Figure 4: calculating aggregate physician-level Lorenz curves."
  )

  provider_volume_tbl <- prepared_tbl |>
    dplyr::group_by(
      specialty = .data$specialty_fixed,
      .data$npi
    ) |>
    dplyr::summarise(
      total_procedures = base::sum(.data$procedures),
      .groups = "drop"
    ) |>
    dplyr::filter(
      include_migs | .data$specialty != "MIGS"
    ) |>
    tibble::as_tibble()

  lorenz_tbl <- provider_volume_tbl |>
    dplyr::arrange(
      .data$specialty,
      .data$total_procedures,
      .data$npi
    ) |>
    dplyr::group_by(.data$specialty) |>
    dplyr::mutate(
      physician_share = dplyr::row_number() /
        dplyr::n(),
      procedure_share = base::cumsum(
        .data$total_procedures
      ) /
        base::sum(.data$total_procedures)
    ) |>
    dplyr::ungroup() |>
    dplyr::select(
      .data$specialty,
      .data$physician_share,
      .data$procedure_share
    ) |>
    tibble::as_tibble()

  origin_tbl <- lorenz_tbl |>
    dplyr::distinct(.data$specialty) |>
    dplyr::mutate(
      physician_share = 0,
      procedure_share = 0
    )

  lorenz_tbl <- dplyr::bind_rows(
    origin_tbl,
    lorenz_tbl
  ) |>
    dplyr::arrange(
      .data$specialty,
      .data$physician_share
    )

  concentration_tbl <- provider_volume_tbl |>
    dplyr::group_by(.data$specialty) |>
    dplyr::summarise(
      physicians = dplyr::n(),
      gini = calculate_gini(.data$total_procedures),
      top_20_share = calculate_top_share(
        .data$total_procedures,
        top_fraction = 0.20
      ),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      label = base::paste0(
        "Gini ",
        scales::number(
          .data$gini,
          accuracy = 0.01
        ),
        "\nTop 20%: ",
        scales::percent(
          .data$top_20_share,
          accuracy = 0.1
        ),
        "\nN = ",
        scales::comma(.data$physicians)
      ),
      label_x = 0.05,
      label_y = 0.93
    ) |>
    tibble::as_tibble()

  figure_plot <- ggplot2::ggplot(
    lorenz_tbl,
    ggplot2::aes(
      x = .data$physician_share,
      y = .data$procedure_share,
      color = .data$specialty
    )
  ) +
    ggplot2::geom_abline(
      slope = 1,
      intercept = 0,
      linetype = "dashed",
      color = "grey55"
    ) +
    ggplot2::geom_line(
      linewidth = 1.1,
      show.legend = FALSE
    ) +
    ggplot2::geom_text(
      data = concentration_tbl,
      mapping = ggplot2::aes(
        x = .data$label_x,
        y = .data$label_y,
        label = .data$label
      ),
      inherit.aes = FALSE,
      hjust = 0,
      vjust = 1,
      size = 3.4
    ) +
    ggplot2::facet_wrap(
      ggplot2::vars(.data$specialty),
      nrow = 1
    ) +
    ggplot2::scale_color_manual(
      values = sling_specialty_palette(),
      drop = FALSE
    ) +
    ggplot2::scale_x_continuous(
      labels = scales::label_percent(
        accuracy = 1
      ),
      limits = base::c(0, 1)
    ) +
    ggplot2::scale_y_continuous(
      labels = scales::label_percent(
        accuracy = 1
      ),
      limits = base::c(0, 1)
    ) +
    ggplot2::coord_equal() +
    ggplot2::labs(
      title = base::paste0(
        "Sling volume was dispersed across many surgeons"
      ),
      subtitle = base::paste0(
        "Curves closer to the diagonal indicate a more equal ",
        "distribution of aggregate physician volume."
      ),
      x = "Cumulative share of physicians",
      y = "Cumulative share of procedures",
      caption = base::paste0(
        "Curves use pooled physician-level volume across observed ",
        "years. MIGS is excluded by default because its small sample ",
        "does not provide a stable specialty-wide estimate."
      )
    ) +
    sling_figure_theme()

  saved_path <- save_sling_plot(
    plot_object = figure_plot,
    file_stem = "figure_4_lorenz_curves",
    save_dir = save_dir,
    run_timestamp = run_timestamp,
    width = 10.5,
    height = 4.6
  )

  base::list(
    plot = figure_plot,
    path = saved_path,
    concentration = concentration_tbl
  )
}


figure_5_state_urps_share_map <- function(
    prepared_tbl,
    save_dir,
    run_timestamp,
    map_year = NULL,
    geometry_year = 2023L) {
  base::message(
    "Figure 5: calculating state-level URPS procedure shares."
  )

  map_source_tbl <- prepared_tbl

  if (!base::is.null(map_year)) {
    map_source_tbl <- map_source_tbl |>
      dplyr::filter(.data$year == map_year)

    base::message(
      "Mapping calendar year ",
      map_year,
      "."
    )
  } else {
    base::message(
      "Mapping pooled procedure shares across all observed years."
    )
  }

  state_share_tbl <- map_source_tbl |>
    dplyr::filter(
      !base::is.na(.data$state_abbr),
      .data$state_abbr != ""
    ) |>
    dplyr::group_by(.data$state_abbr) |>
    dplyr::summarise(
      total_procedures = base::sum(.data$procedures),
      urps_procedures = base::sum(
        .data$procedures[
          .data$specialty_fixed == "URPS"
        ],
        na.rm = TRUE
      ),
      observable_physicians = dplyr::n_distinct(
        .data$npi
      ),
      observable_urps = dplyr::n_distinct(
        .data$npi[
          .data$specialty_fixed == "URPS"
        ]
      ),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      urps_share = .data$urps_procedures /
        .data$total_procedures,
      share_group = dplyr::case_when(
        .data$observable_urps == 0L ~
          "No observable URPS",
        .data$urps_share < 0.25 ~
          "0.1%–24.9%",
        .data$urps_share < 0.50 ~
          "25.0%–49.9%",
        .data$urps_share < 0.75 ~
          "50.0%–74.9%",
        .data$urps_share < 1 ~
          "75.0%–99.9%",
        TRUE ~ "100%"
      ),
      share_group = base::factor(
        .data$share_group,
        levels = base::c(
          "No observable URPS",
          "0.1%–24.9%",
          "25.0%–49.9%",
          "50.0%–74.9%",
          "75.0%–99.9%",
          "100%"
        )
      )
    ) |>
    tibble::as_tibble()

  base::message(
    "Downloading or reading cached Census state geometry."
  )

  state_geometry_sf <- tigris::states(
    cb = TRUE,
    resolution = "20m",
    year = geometry_year,
    progress_bar = FALSE
  ) |>
    dplyr::filter(
      !.data$STUSPS %in% base::c(
        "AS",
        "GU",
        "MP",
        "VI"
      )
    ) |>
    tigris::shift_geometry(
      position = "below"
    )

  mapped_state_sf <- state_geometry_sf |>
    dplyr::left_join(
      state_share_tbl,
      by = base::c(
        "STUSPS" = "state_abbr"
      )
    ) |>
    dplyr::mutate(
      share_group = dplyr::if_else(
        base::is.na(.data$share_group),
        "No observable sling volume",
        base::as.character(.data$share_group)
      ),
      share_group = base::factor(
        .data$share_group,
        levels = base::c(
          "No observable URPS",
          "0.1%–24.9%",
          "25.0%–49.9%",
          "50.0%–74.9%",
          "75.0%–99.9%",
          "100%",
          "No observable sling volume"
        )
      )
    )

  no_urps_sf <- mapped_state_sf |>
    dplyr::filter(
      .data$share_group == "No observable URPS"
    )

  map_title <- if (base::is.null(map_year)) {
    base::paste0(
      "URPS share of observed Medicare sling procedures by state"
    )
  } else {
    base::paste0(
      "URPS share of observed Medicare sling procedures, ",
      map_year
    )
  }

  map_palette <- base::c(
    "No observable URPS" = "#8C8C8C",
    "0.1%–24.9%" = "#D9F0D3",
    "25.0%–49.9%" = "#A6DBA0",
    "50.0%–74.9%" = "#5AAE61",
    "75.0%–99.9%" = "#1B7837",
    "100%" = "#00441B",
    "No observable sling volume" = "#F2F2F2"
  )

  figure_plot <- ggplot2::ggplot(mapped_state_sf) +
    ggplot2::geom_sf(
      mapping = ggplot2::aes(
        fill = .data$share_group
      ),
      color = "white",
      linewidth = 0.25
    ) +
    ggplot2::geom_sf_text(
      data = no_urps_sf,
      mapping = ggplot2::aes(
        label = .data$STUSPS
      ),
      size = 2.7,
      color = "white"
    ) +
    ggplot2::scale_fill_manual(
      values = map_palette,
      drop = FALSE
    ) +
    ggplot2::coord_sf(datum = NA) +
    ggplot2::labs(
      title = map_title,
      subtitle = base::paste0(
        "Labels identify states with sling volume but no observable ",
        "URPS physician above the CMS reporting threshold."
      ),
      fill = "URPS share",
      caption = base::paste0(
        "Shares use provider practice state and observed fee-for-",
        "service Medicare procedures. A state with no observable ",
        "URPS physician may still have URPS physicians below the CMS ",
        "suppression threshold or without qualifying Medicare volume."
      )
    ) +
    sling_figure_theme() +
    ggplot2::theme(
      axis.title = ggplot2::element_blank(),
      axis.text = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank()
    )

  saved_path <- save_sling_plot(
    plot_object = figure_plot,
    file_stem = "figure_5_state_urps_share_map",
    save_dir = save_dir,
    run_timestamp = run_timestamp,
    width = 10,
    height = 6.5
  )

  base::list(
    plot = figure_plot,
    path = saved_path,
    state_summary = state_share_tbl
  )
}


figure_6_entrant_exit_balance <- function(
    flagged_tbl,
    save_dir,
    run_timestamp,
    include_migs = FALSE) {
  base::message(
    "Figure 6: calculating entrants and apparent exits."
  )

  workforce_flow_tbl <- flagged_tbl |>
    dplyr::filter(
      include_migs |
        .data$specialty_fixed != "MIGS"
    ) |>
    dplyr::group_by(
      .data$year,
      specialty = .data$specialty_fixed
    ) |>
    dplyr::summarise(
      Entrants = base::sum(
        .data$entrant,
        na.rm = TRUE
      ),
      `Apparent exits` = -base::sum(
        .data$exiting,
        na.rm = TRUE
      ),
      entrant_defined = base::any(
        !base::is.na(.data$entrant)
      ),
      exit_defined = base::any(
        !base::is.na(.data$exiting)
      ),
      .groups = "drop"
    ) |>
    tidyr::pivot_longer(
      cols = base::c(
        "Entrants",
        "Apparent exits"
      ),
      names_to = "flow_type",
      values_to = "physicians"
    ) |>
    dplyr::filter(
      dplyr::case_when(
        .data$flow_type == "Entrants" ~
          .data$entrant_defined,
        .data$flow_type == "Apparent exits" ~
          .data$exit_defined,
        TRUE ~ FALSE
      )
    ) |>
    tibble::as_tibble()

  figure_plot <- ggplot2::ggplot(
    workforce_flow_tbl,
    ggplot2::aes(
      x = .data$year,
      y = .data$physicians,
      fill = .data$flow_type
    )
  ) +
    ggplot2::geom_hline(
      yintercept = 0,
      linewidth = 0.5
    ) +
    ggplot2::geom_col(
      width = 0.76
    ) +
    ggplot2::facet_wrap(
      ggplot2::vars(.data$specialty),
      ncol = 1,
      scales = "free_y"
    ) +
    ggplot2::scale_fill_manual(
      values = base::c(
        "Entrants" = "#0072B2",
        "Apparent exits" = "#D55E00"
      )
    ) +
    ggplot2::scale_x_continuous(
      breaks = base::sort(
        base::unique(workforce_flow_tbl$year)
      )
    ) +
    ggplot2::scale_y_continuous(
      labels = function(value_vector) {
        scales::comma(base::abs(value_vector))
      },
      expand = ggplot2::expansion(
        mult = base::c(0.08, 0.08)
      )
    ) +
    ggplot2::labs(
      title = base::paste0(
        "URPS entry partly offset attrition in the sling workforce"
      ),
      subtitle = base::paste0(
        "Entrants are above zero; apparent exits are below zero."
      ),
      x = "Calendar year",
      y = "Observable physicians",
      caption = base::paste0(
        "Entrants were absent in both prior observable years; ",
        "apparent exits were absent in both subsequent observable ",
        "years. The first two entrant years and last two exit years ",
        "are undefined. MIGS is excluded by default."
      )
    ) +
    sling_figure_theme()

  saved_path <- save_sling_plot(
    plot_object = figure_plot,
    file_stem = "figure_6_entrant_exit_balance",
    save_dir = save_dir,
    run_timestamp = run_timestamp,
    width = 8.5,
    height = 8
  )

  base::list(
    plot = figure_plot,
    path = saved_path,
    workforce_flow = workforce_flow_tbl
  )
}


create_sling_figures_1_to_6 <- function(
    physician_year_tbl,
    save_dir = "figures",
    excluded_years = integer(0),
    reference_volume = 50,
    map_year = NULL,
    geometry_year = 2023L,
    include_migs_in_concentration = FALSE,
    include_migs_in_workforce_flow = FALSE) {
  base::message("Starting creation of sling Figures 1 through 6.")
  base::message(
    "Input rows: ",
    scales::comma(base::nrow(physician_year_tbl))
  )
  base::message(
    "Requested save directory: ",
    save_dir
  )

  check_sling_figure_packages()

  run_timestamp <- base::format(
    base::Sys.time(),
    "%Y%m%d_%H%M%S"
  )

  prepared_tbl <- prepare_sling_figure_input(
    physician_year_tbl = physician_year_tbl,
    excluded_years = excluded_years
  )

  flagged_tbl <- add_observable_workforce_flags(
    prepared_tbl
  )

  figure_1_artifact <- figure_1_specialty_share(
    prepared_tbl = prepared_tbl,
    save_dir = save_dir,
    run_timestamp = run_timestamp
  )

  figure_2_artifact <- figure_2_workforce_and_volume(
    prepared_tbl = prepared_tbl,
    save_dir = save_dir,
    run_timestamp = run_timestamp
  )

  figure_3_artifact <- figure_3_volume_raincloud(
    prepared_tbl = prepared_tbl,
    save_dir = save_dir,
    run_timestamp = run_timestamp,
    reference_volume = reference_volume
  )

  figure_4_artifact <- figure_4_lorenz_curves(
    prepared_tbl = prepared_tbl,
    save_dir = save_dir,
    run_timestamp = run_timestamp,
    include_migs = include_migs_in_concentration
  )

  figure_5_artifact <- figure_5_state_urps_share_map(
    prepared_tbl = prepared_tbl,
    save_dir = save_dir,
    run_timestamp = run_timestamp,
    map_year = map_year,
    geometry_year = geometry_year
  )

  figure_6_artifact <- figure_6_entrant_exit_balance(
    flagged_tbl = flagged_tbl,
    save_dir = save_dir,
    run_timestamp = run_timestamp,
    include_migs = include_migs_in_workforce_flow
  )

  figure_index_tbl <- tibble::tibble(
    figure = base::paste0(
      "Figure ",
      base::seq_len(6L)
    ),
    path = base::c(
      figure_1_artifact$path,
      figure_2_artifact$path,
      figure_3_artifact$path,
      figure_4_artifact$path,
      figure_5_artifact$path,
      figure_6_artifact$path
    )
  )

  base::message("Completed all six figures.")
  base::message(
    base::paste(
      figure_index_tbl$figure,
      figure_index_tbl$path,
      sep = ": ",
      collapse = "\n"
    )
  )

  base::list(
    files = figure_index_tbl,
    plots = base::list(
      figure_1 = figure_1_artifact$plot,
      figure_2 = figure_2_artifact$plot,
      figure_3 = figure_3_artifact$plot,
      figure_4 = figure_4_artifact$plot,
      figure_5 = figure_5_artifact$plot,
      figure_6 = figure_6_artifact$plot
    ),
    prepared = prepared_tbl,
    workforce_flags = flagged_tbl,
    figure_3_summary = figure_3_artifact$summary,
    figure_4_concentration = figure_4_artifact$concentration,
    figure_5_state_summary = figure_5_artifact$state_summary,
    figure_6_workforce_flow = figure_6_artifact$workforce_flow
  )
}


# Example:
#
# physician_year_tbl <- readr::read_csv(
#   "analysis/physician_year_sling.csv",
#   show_col_types = FALSE
# )
#
# sling_figure_artifacts <- create_sling_figures_1_to_6(
#   physician_year_tbl = physician_year_tbl,
#   save_dir = "manuscript/figures",
#   excluded_years = 2017L,
#   reference_volume = 50,
#   map_year = NULL,
#   geometry_year = 2023L
# )
#
# sling_figure_artifacts$files
