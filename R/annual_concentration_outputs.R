# =============================================================================
# annual_concentration_outputs.R
#
# Reusable builders for the annual (per-year) procedural-concentration tables
# and figures. Factored out so both the pipeline steps (06_make_tables.R,
# 07_make_figures.R) and any ad-hoc refresh call the exact same code — no
# divergent copies of the table/figure logic.
#
# Consumes:
#   annual_concentration  — build_annual_concentration_metrics() output
#   trend_regressions      — build_concentration_trend_regressions() output
#
# Authors: Tyler Muffly, MD
# =============================================================================

# Colorblind-safe palette, shared with 07_make_figures.R. "All" (pooled) is a
# neutral dark line so it reads as the reference rather than a specialty.
.annual_specialty_colors <- c(
  "All"            = "#222222",
  "URPS"           = "#E69F00",
  "MIGS"           = "#CC79A7",
  "General OB/GYN" = "#56B4E9",
  "OB/GYN"         = "#56B4E9",
  "Urology"        = "#009E73",
  "Other"          = "#999999"
)

# Human-readable labels for the measures produced by
# build_annual_concentration_metrics(); also fixes facet/row ordering.
.annual_measure_labels <- c(
  n_procedures     = "Total procedures",
  n_surgeons       = "Observable surgeons",
  median_volume    = "Median annual volume",
  gini_coefficient = "Gini coefficient",
  hhi              = "HHI (0–10,000)",
  pct_by_top_10    = "Share by top 10% (%)",
  pct_by_top_20    = "Share by top 20% (%)",
  pct_by_bottom_50 = "Share by bottom 50% (%)"
)

#' Publication theme (kept local so this file is self-contained).
#' @noRd
.annual_theme <- function() {
  ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(
      plot.title       = ggplot2::element_text(face = "bold", size = 15),
      plot.subtitle    = ggplot2::element_text(size = 10, color = "grey45"),
      legend.position  = "bottom",
      legend.title     = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_line(color = "#f0f0f0"),
      strip.text       = ggplot2::element_text(face = "bold")
    )
}

#' Build the annual concentration table (Table 5) as a formatted tibble.
#' One row per year x specialty (plus pooled "All"), with median (p25-p75)
#' collapsed into a single cell for publication.
#' @noRd
build_annual_concentration_table <- function(annual_concentration, year_col) {
  annual_concentration |>
    dplyr::transmute(
      Year               = .data[[year_col]],
      Specialty          = specialty_group,
      `N surgeons`       = n_surgeons,
      `N procedures`     = n_procedures,
      `Median (p25–p75)` = sprintf(
        "%g (%g–%g)", round(median_volume), round(p25_volume), round(p75_volume)
      ),
      `Gini`             = round(gini_coefficient, 3),
      `HHI`              = round(hhi, 1),
      `Top 10%`          = sprintf("%.1f%%", pct_by_top_10),
      `Top 20%`          = sprintf("%.1f%%", pct_by_top_20),
      `Bottom 50%`       = sprintf("%.1f%%", pct_by_bottom_50)
    )
}

#' Build the concentration trend-regression table (Table 6) as a formatted
#' tibble: one row per specialty x measure with start/end values, slope/yr,
#' R-squared and formatted p.
#' @noRd
build_trend_regression_table <- function(trend_regressions) {
  trend_regressions |>
    dplyr::mutate(
      measure_label = factor(
        .annual_measure_labels[measure],
        levels = .annual_measure_labels
      )
    ) |>
    dplyr::arrange(measure_label, specialty_group) |>
    dplyr::transmute(
      Measure          = as.character(measure_label),
      Specialty        = specialty_group,
      `Start`          = round(start_value, 3),
      `End`            = round(end_value, 3),
      `Slope / year`   = round(slope_per_year, 3),
      `R-squared`      = round(r_squared, 3),
      `p-value`        = p_formatted
    )
}

#' Figure 4 — annual procedural concentration by specialty, faceted over the
#' four concentration measures (Gini, HHI, top-20% share, bottom-50% share).
#' @noRd
make_concentration_trend_figure <- function(annual_concentration, year_col,
                                            year_breaks,
                                            exclude_groups = "MIGS") {
  measures <- c("gini_coefficient", "hhi", "pct_by_top_20", "pct_by_bottom_50")
  # MIGS (n = 10, often 1-4 surgeons/year) yields undefined/extreme annual
  # concentration that dominates the y-axis and hides the signal in the other
  # groups, so it is excluded from the concentration panels by default (it
  # remains in the supply figure). Note the exclusion in the subtitle.
  plot_df <- annual_concentration |>
    dplyr::filter(!specialty_group %in% exclude_groups) |>
    dplyr::select(dplyr::all_of(c(year_col, "specialty_group", measures))) |>
    tidyr::pivot_longer(
      cols = dplyr::all_of(measures),
      names_to = "measure", values_to = "value"
    ) |>
    dplyr::mutate(
      panel = factor(.annual_measure_labels[measure],
                     levels = .annual_measure_labels[measures]),
      specialty_group = factor(
        specialty_group,
        levels = c("All", "URPS", "Urology", "General OB/GYN", "MIGS")
      )
    )

  excl_note <- if (length(exclude_groups)) {
    glue::glue(" ({paste(exclude_groups, collapse = ', ')} excluded: too few surgeons/year for a stable estimate)")
  } else ""

  ggplot2::ggplot(
    plot_df,
    ggplot2::aes(x = .data[[year_col]], y = value,
                 color = specialty_group, group = specialty_group)
  ) +
    ggplot2::geom_line(linewidth = 1.0) +
    ggplot2::geom_point(size = 1.6) +
    ggplot2::facet_wrap(~ panel, scales = "free_y") +
    ggplot2::scale_color_manual(values = .annual_specialty_colors) +
    ggplot2::scale_x_continuous(breaks = year_breaks) +
    ggplot2::labs(
      title    = "Annual Procedural Concentration by Specialty",
      subtitle = glue::glue(
        "CPT 57288 (midurethral sling), Medicare PUF, per calendar year{excl_note}"
      ),
      x = "Year", y = NULL
    ) +
    .annual_theme() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
}

#' Figure 5 — observable surgeons and total procedures per year by specialty.
#' @noRd
make_supply_trend_figure <- function(annual_concentration, year_col,
                                      year_breaks) {
  measures <- c("n_surgeons", "n_procedures")
  plot_df <- annual_concentration |>
    dplyr::filter(specialty_group != "All") |>
    dplyr::select(dplyr::all_of(c(year_col, "specialty_group", measures))) |>
    tidyr::pivot_longer(
      cols = dplyr::all_of(measures),
      names_to = "measure", values_to = "value"
    ) |>
    dplyr::mutate(
      panel = factor(.annual_measure_labels[measure],
                     levels = .annual_measure_labels[measures]),
      specialty_group = factor(
        specialty_group,
        levels = c("URPS", "Urology", "General OB/GYN", "MIGS")
      )
    )

  ggplot2::ggplot(
    plot_df,
    ggplot2::aes(x = .data[[year_col]], y = value,
                 color = specialty_group, group = specialty_group)
  ) +
    ggplot2::geom_line(linewidth = 1.0) +
    ggplot2::geom_point(size = 1.6) +
    ggplot2::facet_wrap(~ panel, scales = "free_y") +
    ggplot2::scale_color_manual(values = .annual_specialty_colors) +
    ggplot2::scale_x_continuous(breaks = year_breaks) +
    ggplot2::scale_y_continuous(labels = scales::comma) +
    ggplot2::labs(
      title    = "Observable Surgeons and Procedure Volume by Specialty",
      subtitle = "CPT 57288 (midurethral sling), Medicare PUF, per calendar year",
      x = "Year", y = NULL
    ) +
    .annual_theme() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
}
