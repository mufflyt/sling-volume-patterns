# News

What changed and why it matters, in plain terms. For the itemized technical
record see [CHANGELOG.md](CHANGELOG.md).

---

## 0.9.0 — Submission preparation (17 August 2026)

The analysis is frozen. This cycle was about getting the manuscript ready for
[*Urogynecology*](https://journals.lww.com/fpmrs/), the official journal of the
[American Urogynecologic Society](https://www.augs.org/), and repairing the
build environment that had rotted since July.

**One real bug reached a deliverable.** The abstract claimed 1,467 physicians
was 1,480. It summed the per-group provider counts, and 13 physicians belong to
two groups across the study period, because the
[time-varying classifier](#classification) moves a physician from general
OB/GYN to URPS in their certification year. Summing groups double-counts them.
The manuscript and the test suite had it right the whole time; only the abstract
was wrong, and only because it used a different formula for the same quantity.
Both now count distinct NPIs.

**Two tables disagreed about the Gini coefficient, correctly.** Table 1 reported
0.28 for OB/GYN-pathway URPS and Table 2 reported 0.51. Both are right: the
first measures inequality across physician-years, the second across physicians
on their aggregate multi-year volume, which runs higher because it also absorbs
how many years each surgeon stayed observable. The Discussion explained this;
the table headers did not. They do now.

**Formatting for the journal.** The manuscript is now double-spaced with
continuous line numbering, which LWW requires and which pandoc does not do by
default. Added a running head, a precis, a word-count line, and a
[STROBE](https://www.strobe-statement.org/) adherence statement, since this is a
cross-sectional observational study.

**Environment repair, documented so it does not recur.** A cold
[renv](https://rstudio.github.io/renv/) restore on macOS needs a Fortran
compiler, because `RcppArmadillo`, `lme4`, `Matrix`, `TMB`, `mgcv`, `nlme` and
`fracdiff` all link against it. Without one the link fails and renv aborts the
entire staged install, leaving an empty library that looks exactly like the
cache-wipe symptom this project has hit before. Install the
[official R toolchain gfortran](https://mac.r-project.org/tools/), which unpacks
to `/opt/gfortran`, the path R's `Makeconf` hardcodes. Binary-only repositories
are not a workaround, and CLAUDE.md now records the four variations that fail
and why.

**Three manuscript figures do not come from the pipeline.** They are produced by
standalone scripts in `scripts/`, and `show_fig()` degrades to a "figure not
found" note rather than failing, so running `00_run_all.R` alone renders a
manuscript quietly missing three of its seven images. Documented in the README.

---

## 0.8.0 — Exclude-mode cohort (23 July 2026)

The primary cohort became identified physicians only. Organizational NPIs
(entity type 2 in [NPPES](https://nppes.cms.hhs.gov/)) and billers whose
specialty cannot be determined are now dropped rather than carried as a sixth
group, so the five physician groups partition the cohort and their shares sum to
100%. The cohort moved from 1,666 billers to 1,467 physicians.

The headline number also changed shape: the paper now leads with the combined
all-pathway URPS share rather than the OB/GYN pathway alone. Both inclusive
handling and the legacy "assign ambiguous billers to urology" approach survive
as sensitivity analyses.

---

## 0.7.0 — Two certification pathways, and a denominator (22 July 2026) {#classification}

**URPS is not one group.** The subspecialty is certifiable from either an
OB/GYN residency or a urology residency, each with its own certifying board. The CMS file reports
urology-pathway URPS surgeons only as "Urology", so any analysis that trusts
CMS provider type alone will undercount urogynecologists and inflate urology.
Cross-referencing both rosters splits them properly.

**The decline is mostly not a decline.** Reported services fell 30.7% over the
period, which sounds dramatic and is largely an artifact: fee-for-service
Medicare enrollment shrank substantially as beneficiaries moved to
[Medicare Advantage](https://www.cms.gov/data-research/statistics-trends-and-reports/medicare-advantagepart-d-contract-and-enrollment-data).
Wiring in the female Part B fee-for-service enrollment denominator turns a 30.7%
drop into a roughly 2.4% per year utilization decline that does not reach
conventional significance. Any version of this finding stated without the
denominator is misleading.

---

## 0.6.0 — The manuscript stopped being typed (21 July 2026)

The manuscript became a knitted [R Markdown](https://rmarkdown.rstudio.com/)
document. `compute_manuscript_values()` returns every scalar and table from the
frozen analysis cache, and the prose references them inline, so a number in the
text cannot disagree with the analysis that produced it. Re-running the analysis
updates the paper.

Also: 2017 came back. The original download was truncated at 1.5 GB against an
expected 2.7 GB, cut mid-record, yielding 376 sling provider-rows instead of the
true 745. It had been excluded outright; the complete file was re-downloaded,
verified, and all 11 years are now analyzed. The lesson, recorded in the README,
is to check file size and row count for the code of interest after any bulk
[CMS](https://data.cms.gov/) download.

---

## 0.5.0 — Concentration, measured properly (20 July 2026)

The central question is whether sling surgery concentrated into fewer hands over
the decade. A single pooled [Gini
coefficient](https://en.wikipedia.org/wiki/Gini_coefficient) cannot answer it,
because a pooled figure rises simply when surgeons are observable for different
numbers of years. Computing concentration *within each calendar year* and
regressing on year answers it directly. It did not concentrate.

Added the [Herfindahl-Hirschman
Index](https://www.justice.gov/atr/herfindahl-hirschman-index) alongside Gini,
with the caveat that both are surgeon-level and must not be read against
antitrust thresholds. Added repeated-measures models
([glmmTMB](https://cran.r-project.org/package=glmmTMB),
[geepack](https://cran.r-project.org/package=geepack)) because provider-year
rows are not independent.

---

## 0.1.0 — Initial pipeline (3 April 2026)

Multi-year CMS Public Use File cache, specialty classification, concentration
metrics, programmatic abstract, tables and figures. certification registry linkage split
OB/GYN into URPS, MIGS and general. FPMRS was renamed URPS throughout, following
the [ABMS](https://www.abms.org/) subspecialty rename.
