# =============================================================================
# 06_make_tables.R
#
# Step 6: Produce all publication tables by reading ONLY from frozen Phase 3
# sub-artifacts.  This script must NEVER call analysis functions.
#
# Phase chain:
#   READS:  data/cache/specialty_summary.rds       [Phase 3 sub-artifact]
#           data/cache/concentration_metrics.rds   [Phase 3 sub-artifact]
#           data/cache/time_trends.rds             [Phase 3 sub-artifact]
#           data/cache/sensitivity_results.rds     [Phase 4 sub-artifact]
#   WRITES: output/tables/table_1_specialty_summary.csv
#           output/tables/table_2_concentration.csv
#           output/tables/table_3_time_trends.csv
#           output/tables/table_s1_sensitivity.csv
#           output/tables/table_4_stats.csv
#
# Authors: Tyler Muffly, MD
# =============================================================================

source("R/artifact_manifest.R")
source("R/reporting_stats_helpers.R")
source("R/annual_concentration_outputs.R")

cfg <- config::get()
set.seed(cfg$seed)

phase_label  <- "06_tables"
phase_script <- "R/06_make_tables.R"

dir.create(cfg$tables_dir, recursive = TRUE, showWarnings = FALSE)

# ── Load Phase 3 sub-artifacts ─────────────────────────────────────────────
specialty_summary <- artifact_read(
  artifact_name = "specialty_summary",
  file_path     = file.path(cfg$cache_dir, "specialty_summary.rds"),
  cache_dir     = cfg$cache_dir,
  verify_hash   = TRUE,
  verbose       = cfg$verbose
)

concentration_metrics <- artifact_read(
  artifact_name = "concentration_metrics",
  file_path     = file.path(cfg$cache_dir, "concentration_metrics.rds"),
  cache_dir     = cfg$cache_dir,
  verify_hash   = TRUE,
  verbose       = cfg$verbose
)

time_trends <- artifact_read(
  artifact_name = "time_trends",
  file_path     = file.path(cfg$cache_dir, "time_trends.rds"),
  cache_dir     = cfg$cache_dir,
  verify_hash   = TRUE,
  verbose       = cfg$verbose
)

# ── Load Phase 4 sensitivity artifact ─────────────────────────────────────
sensitivity_path <- file.path(cfg$cache_dir, "sensitivity_results.rds")
sensitivity_results <- if (file.exists(sensitivity_path)) {
  artifact_read(
    artifact_name = "sensitivity_results",
    file_path     = sensitivity_path,
    cache_dir     = cfg$cache_dir,
    verify_hash   = TRUE,
    verbose       = cfg$verbose
  )
} else {
  message("[06_tables] sensitivity_results.rds not found — skipping Table S1.")
  NULL
}

# =============================================================================
# TABLE 1: Specialty-level summary (with Gini coefficient)
# =============================================================================

table_1 <- specialty_summary |>
  dplyr::transmute(
    Specialty                    = specialty_group,
    `N providers`                = format(n_providers, big.mark = ","),
    `Total slings`               = format(total_slings, big.mark = ","),
    `% of all slings`            = sprintf("%.1f%%", pct_of_all_slings),
    `Median annual volume`       = round(median_annual_volume, 1),
    `Mean annual volume`         = round(mean_annual_volume, 1),
    `Gini coefficient`           = round(gini_coefficient, 3)
  )

artifact_csv(
  tbl           = table_1,
  artifact_name = "table_1_specialty_summary",
  file_path     = file.path(cfg$tables_dir, "table_1_specialty_summary.csv"),
  phase         = phase_label,
  phase_script  = phase_script,
  cache_dir     = cfg$cache_dir,
  verbose       = cfg$verbose
)

message("[06_tables] Table 1 preview:")
print(table_1)

# =============================================================================
# TABLE 2: Concentration metrics by specialty
# =============================================================================

# Build column list dynamically based on available pct_by_top_* columns
top_pct_cols <- grep("^pct_by_top_", names(concentration_metrics), value = TRUE)

table_2 <- concentration_metrics |>
  dplyr::transmute(
    Specialty            = specialty_group,
    `N providers`        = format(n_providers, big.mark = ","),
    `Total slings`       = format(total_slings, big.mark = ","),
    `Gini coefficient`   = round(gini_coefficient, 3)
  )

# Add top-N% columns dynamically
for (col in top_pct_cols) {
  pct_label <- sub("pct_by_top_", "", col)
  table_2[[glue::glue("% by top {pct_label}%")]] <-
    sprintf("%.1f%%", concentration_metrics[[col]])
}

artifact_csv(
  tbl           = table_2,
  artifact_name = "table_2_concentration",
  file_path     = file.path(cfg$tables_dir, "table_2_concentration.csv"),
  phase         = phase_label,
  phase_script  = phase_script,
  cache_dir     = cfg$cache_dir,
  verbose       = cfg$verbose
)

# =============================================================================
# TABLE 3: Annual time trends
# =============================================================================

if (!is.null(time_trends) && nrow(time_trends) > 0) {
  table_3 <- time_trends |>
    dplyr::rename(Year = !!rlang::sym(cfg$year_col_name)) |>
    dplyr::transmute(
      Year                       = Year,
      Specialty                  = specialty_group,
      `Total slings`             = format(total_slings, big.mark = ","),
      `N providers`              = format(n_providers, big.mark = ","),
      `Median annual volume`     = round(median_annual_volume, 1),
      `% slings this year`       = sprintf("%.1f%%", pct_slings_this_year)
    )

  artifact_csv(
    tbl           = table_3,
    artifact_name = "table_3_time_trends",
    file_path     = file.path(cfg$tables_dir, "table_3_time_trends.csv"),
    phase         = phase_label,
    phase_script  = phase_script,
    cache_dir     = cfg$cache_dir,
    verbose       = cfg$verbose
  )
} else {
  message("[06_tables] time_trends is NULL — skipping Table 3.")
}

# =============================================================================
# TABLE S1: Sensitivity analysis (cross-sectional vs multi-year Gini)
# =============================================================================

if (!is.null(sensitivity_results)) {
  table_s1 <- sensitivity_results |>
    dplyr::transmute(
      Specialty                  = specialty_group,
      `Year mode`                = sensitivity_year_mode,
      `N providers`              = format(n_providers, big.mark = ","),
      `Gini coefficient`         = round(gini_coefficient, 3),
      `% of all slings`          = sprintf("%.1f%%", pct_of_all_slings)
    ) |>
    dplyr::arrange(
      `Year mode`,
      Specialty
    )

  artifact_csv(
    tbl           = table_s1,
    artifact_name = "table_s1_sensitivity",
    file_path     = file.path(cfg$tables_dir, "table_s1_sensitivity.csv"),
    phase         = phase_label,
    phase_script  = phase_script,
    cache_dir     = cfg$cache_dir,
    verbose       = cfg$verbose
  )
}

# =============================================================================
# TABLE 4: Statistical tests
# =============================================================================

provider_volume <- artifact_read(
  artifact_name = "provider_volume",
  file_path     = file.path(cfg$cache_dir, "provider_volume.rds"),
  cache_dir     = cfg$cache_dir,
  verify_hash   = TRUE,
  verbose       = cfg$verbose
)
validate_reporting_analysis_output(
  list(
    provider_volume       = provider_volume,
    specialty_summary     = specialty_summary,
    concentration_metrics = concentration_metrics,
    time_trends           = time_trends
  ),
  year_col = cfg$year_col_name
)

# Determine focal groups from data (two largest by total slings, excluding Other)
focal_groups_for_stats <- specialty_summary |>
  dplyr::filter(!specialty_group %in% c("Other")) |>
  dplyr::arrange(dplyr::desc(total_slings)) |>
  dplyr::slice(1:2) |>
  dplyr::pull(specialty_group)

raw_stats_table <- build_focal_stats_table(
  provider_volume,
  focal_groups = focal_groups_for_stats,
  time_trends_tbl = time_trends,
  year_col = cfg$year_col_name
)

table_4_stats <- raw_stats_table |>
  dplyr::transmute(
    Test                    = test,
    Comparison              = dplyr::case_when(
      stringr::str_starts(test, "Kruskal-Wallis") ~ "All specialty groups",
      stringr::str_starts(test, "Wilcoxon") ~ sub("^Wilcoxon \\(Bonferroni\\): ", "", test),
      TRUE ~ "OB/GYN market share over time"
    ),
    `Test statistic`        = round(statistic, 2),
    `Degrees of freedom`    = df,
    `p-value`               = p_formatted
  )

artifact_csv(
  tbl           = table_4_stats,
  artifact_name = "table_4_stats",
  file_path     = file.path(cfg$tables_dir, "table_4_stats.csv"),
  phase         = phase_label,
  phase_script  = phase_script,
  cache_dir     = cfg$cache_dir,
  verbose       = cfg$verbose
)

message("[06_tables] Table 4 (statistical tests via broom::tidy()):")
print(table_4_stats)

# =============================================================================
# TABLE 5 & 6: Annual concentration metrics and their year trends
# =============================================================================

annual_path <- file.path(cfg$cache_dir, "annual_concentration.rds")
if (file.exists(annual_path)) {
  annual_concentration <- artifact_read(
    artifact_name = "annual_concentration",
    file_path     = annual_path,
    cache_dir     = cfg$cache_dir,
    verify_hash   = TRUE,
    verbose       = cfg$verbose
  )

  # Table 5: per year x specialty (+ pooled "All")
  table_5 <- build_annual_concentration_table(
    annual_concentration,
    year_col = cfg$year_col_name
  )
  artifact_csv(
    tbl           = table_5,
    artifact_name = "table_5_annual_concentration",
    file_path     = file.path(cfg$tables_dir, "table_5_annual_concentration.csv"),
    phase         = phase_label,
    phase_script  = phase_script,
    cache_dir     = cfg$cache_dir,
    verbose       = cfg$verbose
  )

  # Table 6: regress each measure on calendar year, per specialty
  trend_regressions <- build_concentration_trend_regressions(
    annual_concentration,
    year_col = cfg$year_col_name
  )
  table_6 <- build_trend_regression_table(trend_regressions)
  artifact_csv(
    tbl           = table_6,
    artifact_name = "table_6_concentration_trends",
    file_path     = file.path(cfg$tables_dir, "table_6_concentration_trends.csv"),
    phase         = phase_label,
    phase_script  = phase_script,
    cache_dir     = cfg$cache_dir,
    verbose       = cfg$verbose
  )
  message("[06_tables] Tables 5 & 6 (annual concentration + trends) written.")
} else {
  message("[06_tables] annual_concentration.rds not found — skipping Tables 5 & 6.")
}

# =============================================================================
# TABLE 1-HTML: kable() + kableExtra publication-formatted version
# =============================================================================

table_1_html_path <- file.path(cfg$tables_dir, "table_1_specialty_summary.html")

table_1_kable <- specialty_summary |>
  dplyr::transmute(
    Specialty              = specialty_group,
    `N providers`          = format(n_providers, big.mark = ","),
    `Total slings`         = format(total_slings, big.mark = ","),
    `% of all slings`      = sprintf("%.1f%%", pct_of_all_slings),
    `Median vol`           = sprintf("%.0f", median_annual_volume),
    `Mean vol`             = sprintf("%.1f", mean_annual_volume),
    `Gini`                 = sprintf("%.3f", gini_coefficient)
  ) |>
  kableExtra::kbl(
    caption = glue::glue(
      "Table 1. Specialty distribution of CPT 57288 providers, ",
      "Medicare PUF {cfg$study_start_year}\u2013{cfg$study_end_year}."
    ),
    booktabs = TRUE,
    align    = c("l", rep("r", 6))
  ) |>
  kableExtra::kable_styling(
    bootstrap_options = c("striped", "hover", "condensed"),
    full_width        = FALSE,
    position          = "left",
    font_size         = 12
  ) |>
  kableExtra::row_spec(0, bold = TRUE) |>
  kableExtra::footnote(
    general = paste0(
      "Gini coefficient ranges from 0 (perfect equality) to 1 (maximum concentration). ",
      "Source: CMS Medicare Physician & Other Practitioners PUF. ",
      "Providers with <11 beneficiaries are suppressed by CMS."
    ),
    general_title = ""
  )

if (rmarkdown::pandoc_available()) {
  kableExtra::save_kable(table_1_kable, file = table_1_html_path)
  message(glue::glue(
    "[06_tables] Table 1 HTML written: {table_1_html_path}"
  ))
} else {
  message("[06_tables] pandoc not found — skipping HTML table. CSV tables are complete.")
}

# ── Final manifest summary for this phase ──────────────────────────────────
message(glue::glue(
  "[{format(Sys.time(), '%Y-%m-%d %H:%M:%S')}] ",
  "[06_tables] All tables written to: {cfg$tables_dir}"
))
manifest_summary(cfg$cache_dir, verbose = cfg$verbose)
