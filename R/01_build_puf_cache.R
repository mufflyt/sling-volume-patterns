# =============================================================================
# 01_build_puf_cache.R
#
# Step 1: Read raw Medicare PUF CSVs from data/raw/, merge multi-year,
# flag CMS-suppressed rows, write data/cache/puf_merged.rds.
#
# Phase chain:
#   READS:  data/raw/Medicare_Provider_Utilization_{YEAR}.csv
#   WRITES: data/cache/puf_merged.rds
#
# Authors: Tyler Muffly, MD
# =============================================================================

source("R/artifact_manifest.R")

cfg         <- config::get()
phase_label <- "01_build_puf_cache"
phase_script <- "R/01_build_puf_cache.R"

# ── Read and merge PUF files ─────────────────────────────────────────────
raw_dir <- cfg$raw_data_dir
years   <- cfg$puf_years
hcpcs   <- cfg$hcpcs_sling_code

message(glue::glue(
  "[{format(Sys.time(), '%Y-%m-%d %H:%M:%S')}] ",
  "[01] Reading PUF files for years: {paste(years, collapse = ', ')}"
))

puf_list <- purrr::map(years, function(yr) {
  # Try common CMS PUF naming conventions
  candidates <- c(
    file.path(raw_dir, glue::glue("Medicare_Provider_Utilization_{yr}.csv")),
    file.path(raw_dir, glue::glue("Medicare_Physician_Other_Practitioners_{yr}.csv")),
    file.path(raw_dir, glue::glue("MUP_PHY_R{yr %% 100}_P05_V10_D{yr}_Prov_Svc.csv"))
  )
  # Also search for actual CMS download filenames (e.g., MUP_PHY_R25_P05_V20_D23_Prov_Svc.csv)
  # where D{yy} is the 2-digit data year and R/P/V vary by release
  yr_short <- sprintf("%02d", yr %% 100)
  glob_matches <- Sys.glob(file.path(raw_dir, glue::glue("MUP_PHY_*_D{yr_short}_Prov_Svc.csv")))
  found <- c(candidates[file.exists(candidates)], glob_matches)
  assertthat::assert_that(
    length(found) >= 1L,
    msg = glue::glue(
      "No PUF file found for year {yr} in {raw_dir}. ",
      "Tried: {paste(basename(candidates), collapse = ', ')}"
    )
  )
  csv_path <- found[1]
  message(glue::glue("  Reading: {basename(csv_path)}"))

  df <- readr::read_csv(
    csv_path,
    col_types = readr::cols(
      Rndrng_NPI        = readr::col_character(),
      Rndrng_Prvdr_Type = readr::col_character(),
      HCPCS_Cd          = readr::col_character(),
      Tot_Srvcs         = readr::col_double(),
      .default          = readr::col_guess()
    ),
    show_col_types = FALSE
  )

  # Filter to CPT 57288 early to reduce memory footprint
  df <- dplyr::filter(df, HCPCS_Cd == hcpcs)

  # Bug fix B10: puf_year from config, not hardcoded
  df[[cfg$year_col_name]] <- yr

  message(glue::glue(
    "    {yr}: {format(nrow(df), big.mark = ',')} rows with HCPCS {hcpcs}"
  ))
  df
})

puf_merged <- dplyr::bind_rows(puf_list)

message(glue::glue(
  "[{format(Sys.time(), '%Y-%m-%d %H:%M:%S')}] ",
  "[01] Merged PUF: {format(nrow(puf_merged), big.mark = ',')} rows across ",
  "{length(years)} years."
))

# ── Flag CMS-suppressed rows ────────────────────────────────────────────
# Bug fix B4: CMS suppresses cells with 1-10 services. Use < threshold (11),
# so rows with Tot_Srvcs 1-10 are flagged. NA values (asterisks in CSV) are
# also flagged.
puf_merged <- dplyr::mutate(
  puf_merged,
  is_cms_suppressed = is.na(Tot_Srvcs) | Tot_Srvcs < cfg$cms_suppression_threshold
)

n_suppressed <- sum(puf_merged$is_cms_suppressed, na.rm = TRUE)
message(glue::glue(
  "[01] CMS suppression flag: {format(n_suppressed, big.mark = ',')} rows ",
  "({sprintf('%.1f', n_suppressed / nrow(puf_merged) * 100)}%)"
))

# ── Write artifact ──────────────────────────────────────────────────────
dir.create(cfg$cache_dir, recursive = TRUE, showWarnings = FALSE)

artifact_write(
  object        = puf_merged,
  artifact_name = "puf_merged",
  file_path     = file.path(cfg$cache_dir, "puf_merged.rds"),
  phase         = phase_label,
  phase_script  = phase_script,
  cache_dir     = cfg$cache_dir,
  verbose       = cfg$verbose
)

message(glue::glue(
  "[{format(Sys.time(), '%Y-%m-%d %H:%M:%S')}] [01] Complete."
))
