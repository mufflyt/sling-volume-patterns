# =============================================================================
# make_classification_flow.R
#
# Provider-classification flow diagram (reviewer #1/#5): how billers of CPT
# 57288 are assigned to specialty groups, with the counts at each step, making
# explicit that facilities and non-physician billers are excluded or set aside
# rather than counted as urologists. Counts come from the frozen cache.
#
# Usage: Rscript scripts/make_classification_flow.R
# Writes: output/figures/figure_classification_flow.png
# =============================================================================

suppressWarnings(suppressMessages({library(dplyr); library(ggplot2)}))
source("R/compute_manuscript_values.R")
cache_dir <- tryCatch(config::get("cache_dir"), error = function(e) "data/cache")
v <- compute_manuscript_values(file.path(cache_dir, "puf_classified.rds"))$v

n <- function(x) format(x, big.mark = ",")
box <- function(x, y, w, h, label, fill = "#eef2f7", col = "#334155", lwd = 0.6)
  list(x = x, y = y, w = w, h = h, label = label, fill = fill, col = col, lwd = lwd)

B <- list(
  top   = box(5.0, 9.2, 6.6, 1.0, sprintf("Billers of CPT 57288, 2013–2023\n1,799 unique NPIs"), "#dbeafe"),
  obg   = box(1.8, 7.0, 3.2, 1.1, "OB/GYN CMS provider type\nsplit by ABOG registry"),
  uro   = box(5.0, 7.0, 3.0, 1.1, sprintf("Urology CMS provider type\n+ ABU roster fold (%d NPIs → URPS)", v$class_abu_pathway)),
  amb   = box(8.3, 7.0, 3.2, 1.1, sprintf("Neither type, not in ABOG\n%d NPIs (mostly facilities, PAs, NPs)", v$class_reclass_urology)),
  fac   = box(7.1, 4.9, 3.0, 1.05, sprintf("Organizations (entity type 2:\nASC, hospital, lab): %d NPIs — EXCLUDED", v$class_excluded_facility), "#fde2e2", "#b91c1c"),
  oth   = box(9.6, 4.9, 3.0, 1.05, sprintf("Non-physician / other clinicians\n%d NPIs → Other/uncertain", v$other_phys), "#f1f5f9"),
  urps  = box(1.3, 2.4, 2.2, 1.0, sprintf("URPS\n%d", v$urps_phys), "#dbeafe"),
  migs  = box(3.6, 2.4, 1.8, 1.0, sprintf("MIGS*\n%d", v$mig_phys), "#f6e6f2"),
  goth  = box(5.7, 2.4, 2.3, 1.0, sprintf("Other non-URPS\nOB/GYN: %d", v$gob_phys), "#e3f0e8"),
  urol  = box(8.2, 2.4, 2.1, 1.0, sprintf("Non-URPS\nurology: %d", v$uro_phys), "#fbe9d8"),
  ouc   = box(10.4, 2.4, 2.1, 1.0, sprintf("Other/\nuncertain: %d", v$other_phys), "#eef1f4"),
  final = box(5.0, 0.5, 7.4, 0.9, sprintf("Analytic cohort: %s clinicians (facilities excluded)", n(v$analytic_physicians)), "#dcfce7", "#166534"))

rects <- do.call(rbind, lapply(B, function(b) data.frame(
  xmin = b$x - b$w/2, xmax = b$x + b$w/2, ymin = b$y - b$h/2, ymax = b$y + b$h/2,
  fill = b$fill, col = b$col, lwd = b$lwd)))
labs <- do.call(rbind, lapply(B, function(b) data.frame(x = b$x, y = b$y, label = b$label)))

seg <- function(a, z, y0 = NULL, y1 = NULL) data.frame(
  x = a$x, xend = z$x,
  y = if (is.null(y0)) a$y - a$h/2 else y0,
  yend = if (is.null(y1)) z$y + z$h/2 else y1)
edges <- rbind(
  seg(B$top, B$obg), seg(B$top, B$uro), seg(B$top, B$amb),
  seg(B$amb, B$fac), seg(B$amb, B$oth),
  seg(B$obg, B$urps), seg(B$obg, B$migs), seg(B$obg, B$goth),
  seg(B$uro, B$urol), seg(B$uro, B$urps),
  seg(B$oth, B$ouc))

p <- ggplot() +
  geom_segment(data = edges, aes(x, y, xend = xend, yend = yend),
               arrow = arrow(length = unit(0.14, "cm"), type = "closed"),
               color = "#94a3b8", linewidth = 0.5) +
  geom_rect(data = rects, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
            fill = rects$fill, color = rects$col, linewidth = rects$lwd) +
  geom_text(data = labs, aes(x, y, label = label), size = 3.5, lineheight = 0.95, color = "#0f172a") +
  annotate("text", x = 5, y = 0.02, size = 2.7, color = "#475569",
           label = "*MIGS estimates are exploratory (10 physicians). Specialty-specific counts exceed the cohort total because some physicians changed groups across years.") +
  coord_cartesian(xlim = c(-0.2, 12.6), ylim = c(-0.3, 9.9), expand = FALSE) +
  labs(title = "Provider classification for CPT 57288 (sling for stress urinary incontinence)") +
  theme_void(base_size = 13) +
  theme(plot.title = element_text(face = "bold", size = 15, hjust = 0.5,
                                  margin = margin(b = 6)))

dir.create("output/figures", showWarnings = FALSE, recursive = TRUE)
out <- "output/figures/figure_classification_flow.png"
ggsave(out, p, width = 11, height = 8, dpi = 300, bg = "white")
message("Wrote ", out)
