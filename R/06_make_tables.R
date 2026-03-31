# =============================================================================
# 06_make_tables.R
#
# Step 6: Produce all publication tables by reading ONLY from frozen Phase 3
# sub-artifacts.  This script must NEVER call analysis functions.
#
# Phase chain:
#   READS:  data/cache/specialty_summary.rds   [Phase 3 sub-artifact]
#           data/cache/low_volume_burden.rds   [Phase 3 sub-artifact]
#           data/cache/time_trends.rds         [Phase 3 sub-artifact]
#           data/cache/sensitivity_results.rds [Phase 4 sub-artifact]
#   WRITES: output/tables/table_1_specialty_summary.csv
#           output/tables/table_2_low_volume_burden.csv
#           output/tables/table_3_time_trends.csv
#           output/tables/table_s1_sensitivity.csv
#
# Stanford pattern: "figure_generation" is a completely separate directory
# from "feature_extraction" — it reads only frozen intermediate files, never
# calls the analysis pipeline. This guarantees tables are reproducible even
# if the analysis code is changed, as long as the artifact hashes match.
#
# Authors: Tyler Muffly, MD
# =============================================================================

source("R/artifact_manifest.R")

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

low_volume_burden <- artifact_read(
  artifact_name = "low_volume_burden",
  file_path     = file.path(cfg$cache_dir, "low_volume_burden.rds"),
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
# TABLE 1: Specialty-level summary
# =============================================================================
# Formatted for direct paste into Word / journal submission system.

table_1 <- specialty_summary |>
  dplyr::transmute(
    Specialty                    = specialty_group,
    `N providers`                = format(n_providers, big.mark = ","),
    `Total slings`               = format(total_slings, big.mark = ","),
    `% of all slings`            = sprintf("%.1f%%", pct_of_all_slings),
    `Median annual volume`       = round(median_annual_volume, 1),
    `Mean annual volume`         = round(mean_annual_volume, 1),
    # Bug fix B1: column header hardcoded 10 instead of reading
    # cfg$low_volume_threshold_primary. If the threshold changes in
    # config.yml the header stays wrong while the values use the new
    # threshold — a silent inconsistency in the published table.
    !!glue::glue("N low-volume (<{cfg$low_volume_threshold_primary}/yr)") :=
      format(n_low_volume_providers, big.mark = ","),
    `% low-volume`               = sprintf("%.1f%%", pct_low_volume_providers)
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
# TABLE 2: Low-volume burden by specialty × stratum
# =============================================================================

table_2 <- low_volume_burden |>
  dplyr::mutate(
    volume_stratum = dplyr::if_else(
      is_low_volume_provider,
      glue::glue("Low-volume (<{cfg$low_volume_threshold_primary}/yr)"),
      glue::glue("High-volume (\u2265{cfg$low_volume_threshold_primary}/yr)")
    )
  ) |>
  dplyr::transmute(
    Specialty        = specialty_group,
    `Volume stratum` = volume_stratum,
    `N providers`    = format(n_providers, big.mark = ","),
    `Total slings`   = format(total_slings, big.mark = ","),
    `% of all slings` = sprintf("%.1f%%", pct_of_all_slings)
  )

artifact_csv(
  tbl           = table_2,
  artifact_name = "table_2_low_volume_burden",
  file_path     = file.path(cfg$tables_dir, "table_2_low_volume_burden.csv"),
  phase         = phase_label,
  phase_script  = phase_script,
  cache_dir     = cfg$cache_dir,
  verbose       = cfg$verbose
)

# =============================================================================
# TABLE 3: Annual time trends (only if time_trends artifact is non-NULL)
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
# TABLE S1: Sensitivity analysis across thresholds
# =============================================================================

if (!is.null(sensitivity_results)) {
  table_s1 <- sensitivity_results |>
    dplyr::transmute(
      Specialty                  = specialty_group,
      `Threshold (slings/yr)`   = sensitivity_threshold,
      `Year mode`                = sensitivity_year_mode,
      `N providers`              = format(n_providers, big.mark = ","),
      `% low-volume`             = sprintf("%.1f%%", pct_low_volume_providers),
      `Delta from primary (%)`   = sprintf("%+.1f%%", pct_low_vol_delta_from_primary)
    ) |>
    dplyr::arrange(
      `Threshold (slings/yr)`,
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
# TABLE 4: Statistical tests — broom::tidy() pattern
# (Pattern 3 from mkiang/excess_physician_mortality + dgarcia-eu/EATLancetR)
#
# broom::tidy() converts every htest/lm/etc. to a standardised tibble with
# columns: statistic, p.value, parameter, method, alternative.
# This replaces manual extraction (result$statistic, result$p.value) and
# ensures the stats table updates automatically when data changes.
# =============================================================================

provider_volume <- artifact_read(
  artifact_name = "provider_volume",
  file_path     = file.path(cfg$cache_dir, "provider_volume.rds"),
  cache_dir     = cfg$cache_dir,
  verify_hash   = TRUE,
  verbose       = cfg$verbose
)

# ── Kruskal-Wallis: annual volume across specialty groups ─────────────────
kruskal_tidy <- stats::kruskal.test(
  annual_sling_count ~ specialty_group,
  data = provider_volume
) |>
  broom::tidy() |>
  dplyr::mutate(comparison = "All specialty groups", test = "Kruskal-Wallis")

# ── Pairwise Wilcoxon (Bonferroni) across focal specialty groups ──────────
focal_groups   <- c("FPMRS", "OB/GYN", "Urology")
focal_volume   <- dplyr::filter(provider_volume, specialty_group %in% focal_groups)
pairwise_tidy  <- stats::pairwise.wilcox.test(
  x               = focal_volume$annual_sling_count,
  g               = focal_volume$specialty_group,
  p.adjust.method = "bonferroni",
  exact           = FALSE
) |>
  broom::tidy() |>
  # Bug fix B3: rename(group2 = group2) was a no-op self-rename that adds
  # noise and warns in newer dplyr. Only rename group1 → comparison;
  # group2 is referenced by name in the mutate below and removed by select.
  dplyr::rename(comparison = group1) |>
  dplyr::mutate(
    comparison = paste(comparison, "vs", group2),
    test       = "Wilcoxon rank-sum (Bonferroni)"
  ) |>
  dplyr::select(-group2)

# ── Chi-square: proportion low-volume across focal groups ─────────────────
npi_summary <- focal_volume |>
  dplyr::group_by(Rndrng_NPI, specialty_group) |>
  dplyr::summarise(
    mean_vol = mean(annual_sling_count, na.rm = TRUE),
    .groups  = "drop"
  ) |>
  dplyr::mutate(is_low_vol = mean_vol < cfg$low_volume_threshold_primary)

chisq_tidy <- stats::chisq.test(
  table(npi_summary$specialty_group, npi_summary$is_low_vol)
) |>
  broom::tidy() |>
  dplyr::mutate(comparison = "FPMRS vs OB/GYN vs Urology", test = "Chi-square")

# ── Bind all tests into one publication-ready tibble ─────────────────────
table_4_stats <- dplyr::bind_rows(kruskal_tidy, pairwise_tidy, chisq_tidy) |>
  dplyr::transmute(
    Test                    = test,
    Comparison              = comparison,
    `Test statistic`        = round(statistic, 2),
    `Degrees of freedom`    = parameter,
    `p-value`               = dplyr::case_when(
      p.value < 0.001 ~ "<0.001",
      p.value < 0.01  ~ sprintf("%.3f", p.value),
      TRUE            ~ sprintf("%.2f",  p.value)
    )
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
# TABLE 1-HTML: kable() + kableExtra publication-formatted version
# (Pattern 3 from dgarcia-eu/EATLancetR)
#
# Writes an HTML file that renders in RStudio Viewer and can be opened in
# Word via File → Open → All Files (kableExtra tables paste cleanly into Word).
# =============================================================================

table_1_html_path <- file.path(cfg$tables_dir, "table_1_specialty_summary.html")

table_1_kable <- specialty_summary |>
  dplyr::transmute(
    Specialty              = specialty_group,
    `N providers`          = format(n_providers, big.mark = ","),
    `Total slings`         = format(total_slings, big.mark = ","),
    `% of all slings`      = sprintf("%.1f%%", pct_of_all_slings),
    # Bug fix B3: column was named "Median vol (IQR)" but only showed
    # the median. The specialty_summary artifact does not carry Q1/Q3,
    # so there is no IQR to display. Renamed to "Median vol" and the
    # footnote reference to IQR removed below.
    `Median vol`           = sprintf("%.0f", median_annual_volume),
    `Mean vol`             = sprintf("%.1f", mean_annual_volume),
    # Bug fix B2: column name contained the literal word "threshold"
    # — not a template variable. The rendered HTML header literally
    # said "<threshold/yr>" regardless of config. Fixed to match the
    # CSV column by using the dynamic threshold from cfg.
    !!glue::glue("N low-vol (<{cfg$low_volume_threshold_primary}/yr)") :=
      format(n_low_volume_providers, big.mark = ","),
    `% low-volume`         = sprintf("%.1f%%", pct_low_volume_providers)
  ) |>
  kableExtra::kbl(
    caption = glue::glue(
      "Table 1. Specialty distribution of CPT 57288 providers, ",
      "Medicare PUF {cfg$study_start_year}–{cfg$study_end_year}. ",
      "Low-volume threshold: <{cfg$low_volume_threshold_primary} procedures/yr."
    ),
    booktabs = TRUE,
    align    = c("l", rep("r", 7))
  ) |>
  kableExtra::kable_styling(
    bootstrap_options = c("striped", "hover", "condensed"),
    full_width        = FALSE,
    position          = "left",
    font_size         = 12
  ) |>
  kableExtra::row_spec(0, bold = TRUE) |>
  # Bug fix B3 (continued): removed IQR explanation from footnote
  # because no IQR is shown anywhere in this table.
  kableExtra::footnote(
    general = glue::glue(
      "Low-volume defined as <{cfg$low_volume_threshold_primary} ",
      "CPT 57288 procedures per year, per provider. ",
      "Source: CMS Medicare Physician & Other Practitioners PUF."
    ),
    general_title = ""
  )

# Save HTML
kableExtra::save_kable(table_1_kable, file = table_1_html_path)
message(glue::glue(
  "[06_tables] Table 1 HTML written: {table_1_html_path}"
))

# ── Final manifest summary for this phase ──────────────────────────────────
message(glue::glue(
  "[{format(Sys.time(), '%Y-%m-%d %H:%M:%S')}] ",
  "[06_tables] All tables written to: {cfg$tables_dir}"
))
manifest_summary(cfg$cache_dir, verbose = cfg$verbose)
