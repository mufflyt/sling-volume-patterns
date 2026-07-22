# =============================================================================
# make_rate_figure.R
#
# Denominator-adjusted utilization figure (reviewer #2): CPT 57288 services per
# 100,000 female Part B fee-for-service Medicare beneficiaries, 2013-2023, with
# the raw service count shown for contrast. Reads the frozen cache and the
# enrollment denominator; degrades gracefully if either is missing.
#
# Usage: Rscript scripts/make_rate_figure.R
# Writes: output/figures/figure_rate_per_100k.png
# =============================================================================

suppressWarnings(suppressMessages({library(dplyr); library(ggplot2)}))
source("R/build_ffs_denominator.R")
source("R/analyze_sling_patterns.R")

cache_dir <- tryCatch(config::get("cache_dir"), error = function(e) "data/cache")
puf <- file.path(cache_dir, "puf_classified.rds")
stopifnot(file.exists(puf))

r  <- analyze_midurethral_sling_patterns(
  readRDS(puf), year_col = "puf_year",
  abog_npi_csv = "data/canonical_abog/canonical_abog_npi_LATEST.csv",
  urps_urology_npi_csv = "data/abu_urology/abu_urps_npi_LATEST.csv", verbose = FALSE)
pv <- r$provider_volume

annual <- pv %>% group_by(year = puf_year) %>%
  summarise(services = sum(annual_sling_count), .groups = "drop")
annual <- attach_ffs_rate(annual, year_col = "year", services_col = "services")

scale_factor <- max(annual$services, na.rm = TRUE) /
                max(annual$rate_per_100k, na.rm = TRUE)

p <- ggplot(annual, aes(x = year)) +
  geom_col(aes(y = services), fill = "grey80", width = 0.65) +
  geom_line(aes(y = rate_per_100k * scale_factor), color = "#1f6feb", linewidth = 1.3) +
  geom_point(aes(y = rate_per_100k * scale_factor), color = "#1f6feb", size = 2.4) +
  geom_vline(xintercept = 2020, linetype = "dotted", color = "grey40") +
  scale_x_continuous(breaks = seq(2013, 2023, 2)) +
  scale_y_continuous(
    name = "Reported services (bars)",
    labels = scales::comma,
    sec.axis = sec_axis(~ . / scale_factor,
                        name = "Services per 100,000 female Part B FFS (line)")) +
  labs(
    title = "Sling services for SUI declined less after denominator adjustment",
    subtitle = "CPT 57288, fee-for-service Medicare, 2013-2023. Line = rate per 100,000 female Part B FFS beneficiaries.",
    x = NULL) +
  theme_minimal(base_size = 15) +
  theme(plot.title = element_text(face = "bold", size = 17),
        plot.subtitle = element_text(size = 12, color = "grey40"),
        axis.title.y.right = element_text(color = "#1f6feb"),
        panel.grid.minor = element_blank())

dir.create("output/figures", showWarnings = FALSE, recursive = TRUE)
out <- "output/figures/figure_rate_per_100k.png"
ggsave(out, p, width = 9, height = 5.5, dpi = 300, bg = "white")
message("Wrote ", out)
