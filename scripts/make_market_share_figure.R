# =============================================================================
# make_market_share_figure.R
#
# Specialty market share of CPT 57288 (sling for SUI), fee-for-service Medicare,
# 2013-2023, with BOTH URPS classification trajectories overlaid (reviewer #2:
# the caption discusses fixed vs certification-gated convergence, so both must
# be visible). Stacked area = fixed-membership specialty shares; the two black
# lines are the URPS share under fixed and certification-gated classification.
# Uses the current classification (facilities excluded, Other/uncertain separate).
#
# Usage: Rscript scripts/make_market_share_figure.R
# Writes: output/figures/figure_market_share.png
# =============================================================================

suppressWarnings(suppressMessages({library(dplyr); library(ggplot2)}))
source("R/build_physician_year_tbl.R")

cache_dir <- tryCatch(config::get("cache_dir"), error = function(e) "data/cache")
puf <- file.path(cache_dir, "puf_classified.rds")
stopifnot(file.exists(puf))
p <- as.data.frame(build_physician_year_tbl(puf))   # plain frame for ggplot

lvl <- c("URPS", "Urology", "Other non-URPS OB/GYN", "Other/uncertain", "MIGS")
relab <- function(x) ifelse(x == "General OB/GYN", "Other non-URPS OB/GYN", x)

area <- p %>%
  mutate(grp = factor(relab(specialty_fixed), levels = lvl)) %>%
  group_by(year, grp) %>% summarise(svc = sum(procedures), .groups = "drop") %>%
  group_by(year) %>% mutate(share = 100 * svc / sum(svc)) %>% ungroup() %>%
  as.data.frame()

traj <- p %>% group_by(year) %>% summarise(
  `Fixed membership`    = 100 * sum(procedures[specialty_fixed == "URPS"]) / sum(procedures),
  `Certification-gated` = 100 * sum(procedures[specialty_cert_gated == "URPS"]) / sum(procedures),
  .groups = "drop") %>%
  tidyr::pivot_longer(-year, names_to = "scheme", values_to = "share") %>%
  as.data.frame()

pal <- c("URPS" = "#1f6feb", "Urology" = "#d1741f",
         "Other non-URPS OB/GYN" = "#2a9d5c", "Other/uncertain" = "#8a8f98",
         "MIGS" = "#c65fb0")

pl <- ggplot() +
  geom_area(data = area, aes(year, share, fill = grp), alpha = 0.85) +
  geom_line(data = traj, aes(year, share, linetype = scheme),
            color = "black", linewidth = 1.1) +
  geom_vline(xintercept = 2020, linetype = "dotted", color = "grey30") +
  scale_fill_manual(values = pal, name = NULL) +
  scale_linetype_manual(values = c("Fixed membership" = "solid",
                                   "Certification-gated" = "dashed"),
                        name = "URPS share (line)") +
  scale_x_continuous(breaks = seq(2013, 2023, 2)) +
  scale_y_continuous(breaks = seq(0, 100, 25)) +
  coord_cartesian(ylim = c(0, 100), expand = FALSE) +
  labs(title = "URPS performs the largest share of Medicare sling services",
       subtitle = "CPT 57288, fee-for-service Medicare, 2013-2023. Black lines: URPS share under two classification scenarios.",
       x = NULL, y = "Share of reported services (%)") +
  theme_minimal(base_size = 15) +
  theme(plot.title = element_text(face = "bold", size = 17),
        plot.subtitle = element_text(size = 11, color = "grey40"),
        legend.position = "bottom",
        panel.grid.minor = element_blank())

dir.create("output/figures", showWarnings = FALSE, recursive = TRUE)
out <- "output/figures/figure_market_share.png"
ggsave(out, pl, width = 9, height = 6, dpi = 300, bg = "white")
message("Wrote ", out)
