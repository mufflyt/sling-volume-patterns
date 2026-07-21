# Midurethral Sling Volume Patterns in Medicare

**Specialty Distribution, Procedural Concentration, and Time Trends for CPT 57288 (Midurethral Sling) Among Medicare Beneficiaries, 2013–2023**

Authors: Tyler Muffly, MD

Target venue: AUGS (American Urogynecologic Society)
Status: Submitted April 2026

---

## Abstract

**OBJECTIVE**
To characterize the specialty distribution, annual procedure volumes, and procedural concentration among physicians performing midurethral sling procedures (CPT 57288) in Medicare beneficiaries.

**METHODS**
We analyzed the CMS Medicare Physician and Other Practitioners Public Use File (2013–2023). Providers billing CPT 57288 were classified as Urogynecology and Reconstructive Pelvic Surgery (URPS), Minimally Invasive Gynecologic Surgery (MIGS), General OB/GYN, or urology using CMS provider type cross-referenced with the ABOG subspecialty registry. Procedural concentration was quantified using Gini coefficients and the share performed by the top 20% of providers. Volume differences were assessed by Kruskal-Wallis and pairwise Wilcoxon tests (Bonferroni-corrected). Gynecologic market-share trends were assessed by linear regression. CMS suppresses counts of 1–10 services; providers below this threshold are absent from the data.

**RESULTS**
A total of 1,775 unique providers billed CPT 57288 across the study period, accounting for 139,855 procedures. URPS physicians represented the largest group, accounting for 52.7% of all procedures at a median annual volume of 19 (IQR 14–29) procedures per year (609 providers). Urology accounted for 823 providers (34.2% of procedures; median 16 (IQR 13–22) procedures per year). General OB/GYN accounted for 333 providers (12.4% of procedures; median 15 (IQR 12–22) procedures per year). MIGS accounted for 10 providers (0.6% of procedures; median 16 (IQR 12–23) procedures per year). Annual sling volume differed significantly across specialty groups (Kruskal-Wallis H = 291.8, df = 3, p <0.001). Annual procedure volume differed significantly between URPS vs Urology (Wilcoxon p <0.001, Bonferroni-corrected). Procedural concentration varied by specialty: URPS (Gini 0.51; top 20% performed 53%); Urology (Gini 0.54; top 20% performed 58.9%); General OB/GYN (Gini 0.56; top 20% performed 61.9%); MIGS (Gini 0.59; top 20% performed 67%). Over the study period, the combined OB/GYN share of procedures increased significantly from 60.3% in 2013 to 69.9% in 2023 (slope = 0.84 percentage points per year; p <0.001).

**CONCLUSIONS**
In this national Medicare cohort, URPS physicians perform the greatest share of midurethral sling procedures in Medicare. Procedural concentration is highest among MIGS providers (Gini 0.59) and lowest among URPS (Gini 0.51), indicating that a minority of providers perform a disproportionate share of procedures. True concentration may be greater, as CMS suppresses claims from providers with fewer than 11 beneficiaries. The combined gynecologic share increased significantly over the study period, with potential workforce implications. These findings inform credentialing standards and workforce planning for pelvic floor surgical care.

---

## Figures

### Figure 1. Market Share of CPT 57288 by Specialty, 2013–2023

![Figure 1](output/figures/figure_1_market_share.png)

The combined gynecologic share (shaded area) increased significantly from 60.3% in 2013 to 69.9% in 2023 (slope = 0.84 percentage points per year; p <0.001). URPS physicians consistently accounted for the largest share, rising from approximately 45% to 58% over the study period. Urology's share declined correspondingly from approximately 40% to 30%. General OB/GYN share decreased modestly from approximately 15% to 11%. MIGS providers contributed less than 1% throughout.

### Figure 2. Annual Procedure Volume Distribution by Specialty

![Figure 2](output/figures/figure_2_volume_distribution.png)

Violin plots with embedded box plots and jittered individual observations show the volume distribution on a log scale. URPS providers had the highest median annual volume (19 procedures; IQR 14–29), followed by MIGS (16; IQR 12–23), Urology (16; IQR 13–22), and General OB/GYN (15; IQR 12–22). All groups showed right-skewed distributions with outlier high-volume providers exceeding 100 procedures per year. The minimum observable volume is 11 due to CMS cell suppression.

### Figure 3. Lorenz Curves of Procedural Concentration by Specialty

![Figure 3](output/figures/figure_3_lorenz_curve.png)

The dashed diagonal represents perfect equality, where each provider performs an equal share of procedures. Curves farther from the diagonal indicate greater concentration. URPS providers (Gini = 0.51) show the most equitable distribution of sling volume, with the curve closest to the diagonal. MIGS (Gini = 0.59) shows the highest concentration, with the bottom 50% of MIGS providers performing less than 25% of MIGS slings. Urology (Gini = 0.54) and General OB/GYN (Gini = 0.56) fall between these extremes.

---

## Key Findings

| Specialty | Providers | Procedures | % Share | Median Vol/yr | Gini |
|-----------|-----------|-----------|---------|---------------|------|
| URPS | 609 | 73,751 | 52.7% | 19 (14–29) | 0.51 |
| Urology | 823 | 47,825 | 34.2% | 16 (13–22) | 0.54 |
| General OB/GYN | 333 | 17,402 | 12.4% | 15 (12–22) | 0.56 |
| MIGS | 10 | 877 | 0.6% | 16 (12–23) | 0.59 |

- **78% of OB/GYNs doing slings are URPS-certified subspecialists** (496 of 609 ABOG-matched providers)
- Gynecologic market share trend is **statistically significant** (p <0.001) with the 11-year time series
- CMS cell suppression (<11 beneficiaries) means all observable providers bill at least 11 slings — true low-volume providers are invisible

---

## How to Run

```bash
# From the project root:

# First time (or returning after months): restore exact R package versions
Rscript -e 'renv::restore()'

# Run the full pipeline
Rscript 00_run_all.R
```

### Reproducible environment

This project uses [`renv`](https://rstudio.github.io/renv/) to lock R package versions. The `renv.lock` file pins 91 packages to the exact versions used for the analysis (R 4.4.0). When returning to this project:

1. `renv::restore()` — installs all packages at the locked versions
2. `renv::status()` — checks if anything has drifted
3. `renv::snapshot()` — updates the lockfile if you add new packages

### Pipeline steps

All parameters are in `config.yml`. The pipeline runs 7 steps:

1. **01_build_puf_cache.R** — Read raw CMS PUF CSVs, filter to CPT 57288, merge across years
2. **02_classify_specialties.R** — Classify providers by CMS provider type
3. **03_run_primary_analysis.R** — Split OB/GYN into URPS/MIGS/General using ABOG registry, compute Gini and concentration metrics, exclude "Other" group
4. **03_run_primary_analysis_sens.R** — Sensitivity: alternative specialty groupings (gynecologic-merged, binary URPS/non-URPS)
5. **04_run_sensitivity_analyses.R** — Cross-sectional vs multi-year Gini comparison
6. **05_generate_abstract.R** — Programmatic abstract with all statistics computed from data
7. **06_make_tables.R** — Publication tables (CSV + HTML), incl. Table 5 (annual concentration) and Table 6 (year trends)
8. **07_make_figures.R** — Market share trend, volume distributions, Lorenz curves, plus Figure 4 (annual concentration) and Figure 5 (supply trends)

### Output files

| File | Description |
|------|-------------|
| `output/abstract.txt` | Programmatic abstract (378 words) |
| `output/tables/table_1_specialty_summary.csv` | Specialty-level summary with Gini |
| `output/tables/table_2_concentration.csv` | Concentration metrics (Gini + HHI, top 10/20/30%) |
| `output/tables/table_3_time_trends.csv` | Annual trends by specialty |
| `output/tables/table_4_stats.csv` | Statistical tests (Kruskal-Wallis, Wilcoxon, trend) |
| `output/tables/table_5_annual_concentration.csv` | Per-year × specialty concentration (surgeons, procedures, median[p25–p75], Gini, HHI, top-10/20%, bottom-50%) |
| `output/tables/table_6_concentration_trends.csv` | OLS trend of each annual measure on calendar year, by specialty |
| `output/tables/table_s1_sensitivity.csv` | Cross-sectional vs multi-year sensitivity |
| `output/figures/figure_1_market_share.png` | Market share time trend |
| `output/figures/figure_2_volume_distribution.png` | Volume distributions (violin + box) |
| `output/figures/figure_3_lorenz_curve.png` | Lorenz curves by specialty |
| `output/figures/figure_4_concentration_trends.png` | Annual Gini/HHI/top-20%/bottom-50% by specialty over time |
| `output/figures/figure_5_supply_trends.png` | Observable surgeons and procedure volume per year by specialty |

---

## Data Sources

- **CMS Medicare Physician & Other Practitioners PUF** (2013–2023): Provider-and-service level claims data. Raw CSVs (~2.7GB each) in `data/raw/`, downloaded from [data.cms.gov](https://data.cms.gov/provider-summary-by-type-of-service/medicare-physician-other-practitioners/medicare-physician-other-practitioners-by-provider-and-service). Not tracked in git.
- **ABOG Subspecialty Registry**: `data/canonical_abog/canonical_abog_npi_LATEST.csv` — NPI-to-subspecialty crosswalk from the American Board of Obstetrics and Gynecology. Used to split OB/GYN providers into URPS, MIGS, and General OB/GYN.
- **ABU urology-pathway URPS roster**: `data/abu_urology/abu_urps_npi_LATEST.csv` — NPIs of fellowship-trained URPS surgeons who entered via a urology residency (American Board of Urology), sourced from the `isochrones` ABU pipeline. The CMS PUF reports these surgeons only as "Urology"; cross-referencing this list folds them into the combined URPS group (config key `urps_urology_npi_csv`; set to empty/remove to keep them in Urology).

---

## Design Decisions (for returning to this project)

1. **Why Gini instead of low-volume thresholds?** CMS suppresses provider-level data when <11 beneficiaries are served. With a low-volume threshold of 10, no providers can be classified as low-volume because they're already removed from the PUF. Gini coefficients and top-N% shares measure concentration within the observable distribution.

2. **Why split OB/GYN?** The ABOG crosswalk revealed that 78% of OB/GYN sling providers are URPS subspecialists. Lumping them together masks a major difference between fellowship-trained urogynecologists and generalists.

3. **Why exclude "Other"?** Only 80 records from General Surgery, undefined types, and osteopathic specialties. Too heterogeneous and small to interpret meaningfully.

4. **Why 2013 start?** CMS PUF begins in 2013. The 2012 data was published in an earlier format that has been superseded. Extending from 2017–2023 to 2013–2023 made the gynecologic market share trend statistically significant (p=0.10 → p<0.001).

5. **FPMRS → URPS rename:** The subspecialty was renamed from "Female Pelvic Medicine and Reconstructive Surgery" to "Urogynecology and Reconstructive Pelvic Surgery" by ABMS. The code uses "URPS" throughout.

6. **Combined URPS (both training pathways):** URPS is certifiable from either an OB/GYN or a urology residency. The ABOG registry captures only the OB/GYN pathway; urology-pathway URPS surgeons appear as "Urology" in the CMS PUF. Step 2c of `analyze_midurethral_sling_patterns()` cross-references the ABU roster (`urps_urology_npi_csv`) and promotes those NPIs into a single combined URPS group, leaving Urology as non-URPS urology. Note: this makes "URPS + MIGS + General OB/GYN" no longer purely OB/GYN-trained, so revisit any "gynecologic share" wording.

7. **Annual concentration, not just one pooled Gini:** `build_annual_concentration_metrics()` computes every concentration measure per calendar year (overall and by specialty) — total procedures, observable surgeons, median[p25–p75], Gini, HHI, top-10/20% and bottom-50% shares — and `build_concentration_trend_regressions()` regresses each on year. This distinguishes *within-year* concentration (was ~0.27 and stable) from cumulative *multi-year* concentration (~0.52), answering whether care concentrated over time rather than reporting a single pooled value. Refresh from the cached `provider_volume`/`puf_classified` without re-reading raw CSVs via `scripts/refresh_annual_concentration.R`.

---

## Project Structure

```
sling-volume-patterns/
├── 00_run_all.R                    # Master pipeline orchestration
├── config.yml                      # All parameters (years, cutoffs, paths)
├── R/
│   ├── 01_build_puf_cache.R        # Step 1: Read/merge PUF CSVs
│   ├── 02_classify_specialties.R   # Step 2: CMS provider type classification
│   ├── 03_run_primary_analysis.R   # Step 3: ABOG split + concentration analysis
│   ├── 03_run_primary_analysis_sens.R  # Step 3s: Sensitivity specialty schemes
│   ├── 04_run_sensitivity_analyses.R   # Step 4: Cross-sectional vs multi-year
│   ├── 05_generate_abstract.R      # Step 5: Programmatic abstract
│   ├── 06_make_tables.R            # Step 6: Publication tables
│   ├── 07_make_figures.R           # Step 7: Publication figures
│   ├── analyze_sling_patterns.R    # Core analysis functions (Gini, classification)
│   ├── generate_sling_abstract.R   # Abstract section builders
│   ├── reporting_stats_helpers.R   # Statistical test helpers
│   └── artifact_manifest.R         # Reproducibility/caching system
├── data/
│   ├── raw/                        # Original CMS CSVs (not in git)
│   ├── cache/                      # Pipeline artifacts (.rds)
│   └── canonical_abog/             # ABOG NPI crosswalk
└── output/
    ├── abstract.txt                # Generated abstract
    ├── tables/                     # CSV + HTML tables
    └── figures/                    # PNG figures
```

---

## R Dependencies

`readr`, `dplyr`, `purrr`, `glue`, `stringr`, `ggplot2`, `scales`, `kableExtra`, `rmarkdown`, `broom`, `assertthat`, `config`, `here`, `vroom`, `furrr`, `future`, `tibble`, `rlang`
