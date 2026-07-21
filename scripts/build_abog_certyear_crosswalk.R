# =============================================================================
# build_abog_certyear_crosswalk.R
#
# Derive the ABOG subspecialty certification-year crosswalk used by the
# time-varying cert-gated classification. Reads the full canonical ABOG file
# (which carries `sub1startdate` — the true FPMRS/MIG subspecialty certification
# date, distinct from the initial OB/GYN board date in `startdate`) and writes:
#   data/canonical_abog/abog_subspecialty_certyear_LATEST.csv   (npi, subspecialty, cert_year)
#
# Usage: Rscript scripts/build_abog_certyear_crosswalk.R [full_canonical_abog.csv]
# =============================================================================

suppressWarnings(suppressMessages(library(dplyr)))

args <- commandArgs(trailingOnly = TRUE)
src <- if (length(args) >= 1) args[[1]] else
  "/Users/tylermuffly/isochrones/data/canonical_abog/canonical_abog_npi_LATEST.csv"
stopifnot(file.exists(src))

d <- readr::read_csv(src, show_col_types = FALSE, guess_max = 100000)
stopifnot(all(c("npi", "subspecialty", "sub1startdate") %in% names(d)))

cw <- d |>
  filter(
    subspecialty %in% c(
      "Female Pelvic Medicine and Reconstructive Surgery",
      "Female Pelvic Medicine & Reconstructive Surgery", "MIG"
    ),
    !is.na(npi), !is.na(sub1startdate)
  ) |>
  transmute(
    npi          = trimws(as.character(npi)),
    subspecialty = ifelse(grepl("Pelvic", subspecialty), "URPS", "MIGS"),
    cert_year    = as.integer(substr(as.character(sub1startdate), 1, 4))
  ) |>
  filter(!is.na(cert_year), cert_year >= 2011) |>   # subspecialty certs begin 2013
  distinct(npi, subspecialty, .keep_all = TRUE)

out <- "data/canonical_abog/abog_subspecialty_certyear_LATEST.csv"
readr::write_csv(cw, out)
cat(sprintf("Wrote %d rows (%d URPS, %d MIGS) to %s\n",
            nrow(cw), sum(cw$subspecialty == "URPS"),
            sum(cw$subspecialty == "MIGS"), out))
cat("cert_year range:", paste(range(cw$cert_year), collapse = "-"), "\n")
