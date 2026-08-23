# =============================================================================
# make_market_share_figure.R
#
# Specialty market share of CPT 57288 (sling for SUI), fee-for-service Medicare,
# 2013-2023. Stacked area = fixed-membership specialty shares with URPS split by
# certification pathway (OB/GYN vs urology). The two black lines are the
# COMBINED all-pathway URPS share under fixed and certification-gated
# classification (the certification-timing sensitivity, which is about the
# aggregate URPS group). Uses the current classification (facilities excluded,
# Other/uncertain separate).
#
# Usage: Rscript scripts/make_market_share_figure.R
# Writes: output/figures/figure_market_share.png
# =============================================================================

suppressWarnings(suppressMessages({library(dplyr); library(ggplot2)}))
source("R/analyze_sling_patterns.R")
source("R/build_physician_year_tbl.R")

cache_dir <- tryCatch(config::get("cache_dir"), error = function(e) "data/cache")
puf <- file.path(cache_dir, "puf_classified.rds")
stopifnot(file.exists(puf))

# Six-group per-year shares for the stacked area.
pv <- analyze_midurethral_sling_patterns(
  readRDS(puf), year_col = "puf_year",
  abog_npi_csv = "data/canonical_abog/canonical_abog_npi_LATEST.csv",
  urps_urology_npi_csv = "data/abu_urology/abu_urps_npi_LATEST.csv",
  other_handling = "separate", split_urps_pathway = TRUE, verbose = FALSE)$provider_volume

source("R/specialty_groups.R")
lvl <- sg_display(sg_codes("all"))
relab <- function(x) sg_display(x)

area <- pv %>%
  mutate(grp = factor(relab(specialty_group), levels = lvl)) %>%
  group_by(year = puf_year, grp) %>% summarise(svc = sum(annual_sling_count), .groups = "drop") %>%
  group_by(year) %>% mutate(share = 100 * svc / sum(svc)) %>% ungroup() %>% as.data.frame()

# Combined all-pathway URPS trajectory under the two classification scenarios.
p <- as.data.frame(build_physician_year_tbl(puf))
traj <- p %>% group_by(year) %>% summarise(
  `Fixed membership`    = 100 * sum(procedures[specialty_fixed == "URPS"]) / sum(procedures),
  `Certification-gated` = 100 * sum(procedures[specialty_cert_gated == "URPS"]) / sum(procedures),
  .groups = "drop") %>%
  tidyr::pivot_longer(-year, names_to = "scheme", values_to = "share") %>% as.data.frame()

# Keyed by display label from the taxonomy; this figure keeps its own hues
# rather than the Okabe-Ito set used by the supplementary panels.
pal <- stats::setNames(
  c("#1f6feb", "#7ba9f5", "#d1741f", "#2a9d5c", "#8a8f98", "#c65fb0"),
  sg_display(c("URPS (OB/GYN)", "URPS (urology)", "Urology",
               "General OB/GYN", "Other/uncertain", "MIGS")))

pl <- ggplot() +
  geom_area(data = area, aes(year, share, fill = grp), alpha = 0.9) +
  geom_line(data = traj, aes(year, share, linetype = scheme),
            color = "black", linewidth = 1.1) +
  geom_vline(xintercept = 2020, linetype = "dotted", color = "grey30") +
  scale_fill_manual(values = pal, name = NULL) +
  scale_linetype_manual(values = c("Fixed membership" = "solid",
                                   "Certification-gated" = "dashed"),
                        name = "Combined URPS share (line)") +
  scale_x_continuous(breaks = seq(2013, 2023, 2)) +
  scale_y_continuous(breaks = seq(0, 100, 25)) +
  coord_cartesian(ylim = c(0, 100), expand = FALSE) +
  guides(fill = guide_legend(nrow = 2, order = 2, byrow = TRUE),
         linetype = guide_legend(nrow = 2, order = 1, byrow = TRUE)) +
  labs(title = "URPS performs the largest share of Medicare sling services",
       subtitle = paste0("CPT 57288, fee-for-service Medicare, 2013-2023. URPS split by certification pathway;\n",
                         "black lines = combined URPS share under two scenarios."),
       x = NULL, y = "Share of reported services (%)") +
  theme_minimal(base_size = 15) +
  theme(plot.title = element_text(face = "bold", size = 17),
        plot.subtitle = element_text(size = 10.5, color = "grey40"),
        legend.position = "bottom",
        legend.box = "vertical",
        legend.text = element_text(size = 11),
        legend.key.width = unit(0.9, "cm"),
        panel.grid.minor = element_blank(),
        plot.margin = margin(t = 10, r = 16, b = 10, l = 10))

dir.create("output/figures", showWarnings = FALSE, recursive = TRUE)
out <- "output/figures/figure_market_share.png"
ggsave(out, pl, width = 9.5, height = 6, dpi = 300, bg = "white")
message("Wrote ", out)
