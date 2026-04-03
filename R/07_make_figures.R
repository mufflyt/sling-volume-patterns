# =============================================================================
# 07_make_figures.R
#
# Step 7: Produce publication figures from frozen Phase 3 artifacts.
# This script reads ONLY from data/cache/ — never calls analysis functions.
#
# Figures:
#   Figure 1: FPMRS market share time trend (line plot)
#   Figure 2: Annual volume distributions by specialty (box/violin)
#
# Phase chain:
#   READS:  data/cache/time_trends.rds      [Phase 3 sub-artifact]
#           data/cache/provider_volume.rds  [Phase 3 sub-artifact]
#   WRITES: output/figures/figure_1_market_share.png
#           output/figures/figure_2_volume_distribution.png
#
# Authors: Tyler Muffly, MD
# =============================================================================

source("R/artifact_manifest.R")

cfg          <- config::get()
phase_label  <- "07_figures"
phase_script <- "R/07_make_figures.R"

dir.create(cfg$figures_dir, recursive = TRUE, showWarnings = FALSE)

# ── Load Phase 3 artifacts ───────────────────────────────────────────────
time_trends <- artifact_read(
  artifact_name = "time_trends",
  file_path     = file.path(cfg$cache_dir, "time_trends.rds"),
  cache_dir     = cfg$cache_dir,
  verify_hash   = TRUE,
  verbose       = cfg$verbose
)

provider_volume <- artifact_read(
  artifact_name = "provider_volume",
  file_path     = file.path(cfg$cache_dir, "provider_volume.rds"),
  cache_dir     = cfg$cache_dir,
  verify_hash   = TRUE,
  verbose       = cfg$verbose
)

# ── Publication theme ────────────────────────────────────────────────────
theme_publication <- function() {
  ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(
      plot.title       = ggplot2::element_text(face = "bold", size = 16),
      plot.subtitle    = ggplot2::element_text(size = 11, color = "grey45"),
      legend.position  = "bottom",
      legend.title     = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_line(color = "#f0f0f0"),
      axis.line        = ggplot2::element_line(color = "#cccccc"),
      strip.text       = ggplot2::element_text(face = "bold")
    )
}

# Color palette: colorblind-safe, distinct for specialty groups
specialty_colors <- c(
  "FPMRS"          = "#E69F00",
  "MIGS"           = "#CC79A7",
  "General OB/GYN" = "#56B4E9",
  "OB/GYN"         = "#56B4E9",
  "Urology"        = "#009E73",
  "Other"          = "#999999"
)

# =============================================================================
# FIGURE 1: FPMRS Market Share Time Trend
# =============================================================================

if (!is.null(time_trends) && nrow(time_trends) > 0) {
  year_col <- cfg$year_col_name

  # Combine gynecologic groups for the area highlight
  gyn_groups <- c("OB/GYN", "FPMRS", "MIGS", "General OB/GYN")
  area_data <- time_trends |>
    dplyr::filter(specialty_group %in% gyn_groups) |>
    dplyr::group_by(dplyr::across(dplyr::all_of(year_col))) |>
    dplyr::summarise(
      pct_slings_this_year = sum(pct_slings_this_year, na.rm = TRUE),
      .groups = "drop"
    )

  fig1 <- ggplot2::ggplot(time_trends) +
    ggplot2::geom_area(
      data = area_data,
      ggplot2::aes(
        x = .data[[year_col]],
        y = pct_slings_this_year
      ),
      fill = "#4C9AFF",
      alpha = 0.2
    ) +
    ggplot2::geom_line(
      ggplot2::aes(
        x     = .data[[year_col]],
        y     = pct_slings_this_year,
        color = specialty_group,
        group = specialty_group
      ),
      linewidth = 1.4
    ) +
    ggplot2::geom_point(
      ggplot2::aes(
        x     = .data[[year_col]],
        y     = pct_slings_this_year,
        color = specialty_group
      ),
      size = 3,
      stroke = 0.5,
      shape = 21,
      fill = "white"
    ) +
    ggplot2::scale_color_manual(values = specialty_colors) +
    ggplot2::scale_x_continuous(breaks = cfg$puf_years) +
    ggplot2::scale_y_continuous(
      labels = function(x) paste0(x, "%"),
      limits = c(0, NA)
    ) +
    ggplot2::labs(
      title    = "Market Share of CPT 57288 by Specialty",
      subtitle = glue::glue(
        "Medicare PUF, {cfg$study_start_year}\u2013{cfg$study_end_year}"
      ),
      x = "Year",
      y = "Share of all midurethral slings (%)"
    ) +
    theme_publication() +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(fill = "#fcfcfd", color = NA)
    ) +
    ggplot2::annotate(
      "text",
      x = cfg$study_start_year + 1,
      y = max(area_data$pct_slings_this_year, na.rm = TRUE) + 3,
      label = "Gynecologic share",
      color = "#0C4DA2",
      size = 4,
      hjust = 0
    )

  fig1_path <- file.path(cfg$figures_dir, "figure_1_market_share.png")
  ggplot2::ggsave(
    filename = fig1_path,
    plot     = fig1,
    width    = 8,
    height   = 5,
    dpi      = 300,
    bg       = "white"
  )
  message(glue::glue("[07] Figure 1 saved: {fig1_path}"))
} else {
  message("[07] time_trends is NULL or empty -- skipping Figure 1.")
}

# =============================================================================
# FIGURE 2: Annual Volume Distribution by Specialty
# =============================================================================

if (nrow(provider_volume) > 0) {
  # Order specialties by median volume for cleaner visualization
  specialty_order <- provider_volume |>
    dplyr::group_by(specialty_group) |>
    dplyr::summarise(
      med_vol = stats::median(annual_sling_count, na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::arrange(dplyr::desc(med_vol)) |>
    dplyr::pull(specialty_group)

  plot_data <- dplyr::mutate(
    provider_volume,
    specialty_group = factor(specialty_group, levels = specialty_order)
  )

  fig2 <- ggplot2::ggplot(
    plot_data,
    ggplot2::aes(
      x    = specialty_group,
      y    = annual_sling_count,
      fill = specialty_group
    )
  ) +
    ggplot2::geom_violin(alpha = 0.8, scale = "width", color = NA) +
    ggplot2::geom_boxplot(
      width        = 0.19,
      outlier.shape = NA,
      alpha        = 0.95,
      color        = "grey20"
    ) +
    ggplot2::geom_jitter(
      size  = 0.9,
      alpha = 0.25,
      width = 0.12,
      color = "grey20"
    ) +
    ggplot2::scale_fill_manual(values = specialty_colors) +
    ggplot2::scale_y_continuous(
      trans  = "log1p",
      breaks = c(1, 5, 10, 25, 50, 100, 200, 500),
      labels = scales::comma,
      expand = c(0, 0)
    ) +
    ggplot2::labs(
      title    = "Annual Procedure Volume by Specialty",
      subtitle = glue::glue(
        "CPT 57288 (midurethral sling), Medicare PUF ",
        "{cfg$study_start_year}\u2013{cfg$study_end_year}"
      ),
      x = NULL,
      y = "Annual sling count per provider (log scale)"
    ) +
    theme_publication() +
    ggplot2::theme(
      legend.position = "none",
      panel.grid.major.x = ggplot2::element_blank()
    )

  fig2_path <- file.path(cfg$figures_dir, "figure_2_volume_distribution.png")
  ggplot2::ggsave(
    filename = fig2_path,
    plot     = fig2,
    width    = 7,
    height   = 5,
    dpi      = 300,
    bg       = "white"
  )
  message(glue::glue("[07] Figure 2 saved: {fig2_path}"))
} else {
  message("[07] provider_volume is empty -- skipping Figure 2.")
}

# =============================================================================
# FIGURE 3: Lorenz Curve by Specialty (procedural concentration)
# =============================================================================

if (nrow(provider_volume) > 0) {
  # Build Lorenz curve data: for each specialty, compute cumulative share
  # of providers (x) vs cumulative share of procedures (y)
  lorenz_data <- provider_volume |>
    dplyr::group_by(specialty_group, Rndrng_NPI) |>
    dplyr::summarise(
      total_vol = sum(annual_sling_count, na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::group_by(specialty_group) |>
    dplyr::arrange(total_vol, .by_group = TRUE) |>
    dplyr::mutate(
      cum_providers = seq_len(dplyr::n()) / dplyr::n(),
      cum_slings    = cumsum(total_vol) / sum(total_vol)
    ) |>
    dplyr::ungroup()

  # Add origin points for each specialty
  origin_rows <- lorenz_data |>
    dplyr::distinct(specialty_group) |>
    dplyr::mutate(
      cum_providers = 0,
      cum_slings    = 0,
      total_vol     = NA_real_,
      Rndrng_NPI    = NA_character_
    )
  lorenz_data <- dplyr::bind_rows(origin_rows, lorenz_data)

  fig3 <- ggplot2::ggplot(
    lorenz_data,
    ggplot2::aes(
      x     = cum_providers,
      y     = cum_slings,
      color = specialty_group
    )
  ) +
    ggplot2::geom_abline(
      slope = 1, intercept = 0,
      linetype = "dashed", color = "grey60"
    ) +
    ggplot2::geom_line(linewidth = 1.2) +
    ggplot2::scale_color_manual(values = specialty_colors) +
    ggplot2::scale_x_continuous(
      labels = scales::percent,
      expand = c(0, 0)
    ) +
    ggplot2::scale_y_continuous(
      labels = scales::percent,
      expand = c(0, 0)
    ) +
    ggplot2::labs(
      title    = "Lorenz Curve: Procedural Concentration by Specialty",
      subtitle = glue::glue(
        "CPT 57288 (midurethral sling), Medicare PUF ",
        "{cfg$study_start_year}\u2013{cfg$study_end_year}"
      ),
      x = "Cumulative share of providers (ranked by volume)",
      y = "Cumulative share of procedures"
    ) +
    theme_publication() +
    ggplot2::coord_equal()

  fig3_path <- file.path(cfg$figures_dir, "figure_3_lorenz_curve.png")
  ggplot2::ggsave(
    filename = fig3_path,
    plot     = fig3,
    width    = 7,
    height   = 7,
    dpi      = 300,
    bg       = "white"
  )
  message(glue::glue("[07] Figure 3 saved: {fig3_path}"))
} else {
  message("[07] provider_volume is empty -- skipping Figure 3.")
}

# ── Done ─────────────────────────────────────────────────────────────────
message(glue::glue(
  "[{format(Sys.time(), '%Y-%m-%d %H:%M:%S')}] [07] All figures complete."
))
