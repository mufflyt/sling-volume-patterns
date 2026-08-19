# Changelog

Technical change log for the analysis pipeline. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/). For the narrative
version of what changed and why it matters scientifically, see [NEWS.md](NEWS.md).

Dates are the dates of the underlying commits. Versions are retrospective:
the project was not tagged during development.

## [Unreleased]

Nothing yet.

## [0.9.0] - 2026-08-17

Submission-preparation release. The analysis is frozen; changes in this cycle
were environment repair, one real analytic bug, and journal formatting.

### Fixed

- **Abstract reported the wrong cohort size.** The cohort total was computed as
  `sum(specialty_summary$n_providers)`, a sum of per-group distinct counts. 13
  physicians occupy two groups across the study period under the time-varying
  cert-gated classifier, so the sum double-counted them and printed 1,480 where
  the manuscript and the test golden values both said 1,467. The prose called
  the figure "unique providers", making it a factual misstatement rather than a
  different convention. Now `n_distinct(Rndrng_NPI)`, in both the prose and the
  `filled_values` audit record so the two cannot drift apart.
- **Two different Gini columns shared one label.** Table 1 computes Gini across
  physician-year rows; Table 2 computes it across physicians on aggregate
  multi-year volume. Both headers read "Gini coefficient", so URPS (OB/GYN)
  appeared as 0.28 in one table and 0.51 in the other with nothing to explain
  the gap. Headers now name their denominator.
- **The renv repair recipe in CLAUDE.md never worked.** It searched
  `-maxdepth 3`, but package symlinks live one level deeper at
  `renv/library/macos/R-4.4/aarch64-apple-darwin20/<pkg>`. The find matched
  nothing, reported success, and `renv::restore()` then treated 90 dangling
  links as installed packages and skipped every one.
- **Re-rendering the manuscript silently dropped three figures.**
  `manuscript.Rmd` embeds `figure_market_share`, `figure_rate_per_100k` and
  `figure_classification_flow`, which are produced by standalone scripts in
  `scripts/` rather than by any numbered pipeline step. `show_fig()` degrades to
  a "Figure not found" note instead of failing, so the render succeeded while
  losing three of seven images.

### Added

- `templates/urogynecology_reference.docx` carrying double spacing and
  continuous line numbering, both required for LWW submission and both absent
  while `reference_docx` was `null`.
- Running head, precis, word-count line, and a STROBE adherence statement.
- `CITATION.cff`, `CHANGELOG.md`, `NEWS.md`, and web-sized README figures in
  `docs/figures/`.
- gfortran documented in CLAUDE.md as a hard requirement for a cold restore,
  with the four binary-only workarounds that do not work and why.

### Changed

- Data-availability statement and the Methods reproducibility sentence now
  point at the corresponding author rather than the repository.

## [0.8.0] - 2026-07-23

### Changed

- **Primary cohort is now identified physicians only** (`other_handling:
  "exclude"`). Organizational NPIs (NPPES entity type 2) and unclassifiable
  billers are dropped rather than carried as a sixth group, so the five
  physician groups partition the cohort. Cohort moved from 1,666 billers /
  141,009 services to 1,467 physicians / 129,517 services. The inclusive
  handling is retained as a sensitivity, as is the legacy approach of assigning
  ambiguous billers to urology (1,789).
- **Primary estimand is the combined all-pathway URPS share** under fixed
  membership, 58.6% to 75.4% across the period. Abstract, Results and
  Discussion now lead with the combined figure (69.3%) rather than the
  OB/GYN-pathway figure alone.

### Fixed

- Table 4 label bug and other errors confirmed in the third review round.

## [0.7.0] - 2026-07-22

### Added

- **URPS split by certification pathway.** URPS is certifiable from either an
  OB/GYN or a urology residency, and the CMS PUF reports urology-pathway URPS
  surgeons only as "Urology". Cross-referencing the urology-pathway certification roster separates
  OB/GYN-pathway from urology-pathway URPS instead of collapsing them.
- Fee-for-service enrollment denominator, which is what separates the raw 30.7%
  decline in reported services from the much smaller enrollment-adjusted
  utilization decline.
- Facility exclusion by NPPES entity type 2 rather than name regex alone.
- Test suite covering classification, concentration and golden values.

### Changed

- Nine revision phases responding to review: procedure re-definition,
  concentration rework, full model rework, classification reproducibility,
  downgraded workforce claims, display reorganization, and journal formatting.
- renv cache disabled per-project so packages land as real directories,
  ending the recurring library-loss failures.

## [0.6.0] - 2026-07-21

### Added

- **Reproducible manuscript** (`output/manuscript.Rmd`, pipeline step 08).
  `compute_manuscript_values()` returns roughly 120 scalars and tables from the
  frozen cache, and the Rmd references them inline, so the prose cannot drift
  from the analysis.
- Twenty cited references and an expanded Discussion.
- Complete 2017 data. The original D17 download was truncated at 1.5 GB versus
  the expected 2.7 GB, cut mid-record, yielding 376 sling provider-rows instead
  of the true 745. It had been excluded via `exclude_years`; the full file was
  re-downloaded and verified, and all 11 years are now analyzed.

### Fixed

- Cert-gated denominator bug that inflated the 2023 URPS share to 74.2% when
  computed on an Other-excluded base; correct value 62.8%.

## [0.5.0] - 2026-07-20

### Added

- Annual (within-year) concentration measures, distinguishing within-year
  concentration from pooled multi-year concentration. This is the distinction
  that supports the paper's central negative finding: case volume did not
  concentrate over the decade.
- HHI alongside Gini, both surgeon-level.
- Repeated-measures volume models (negative-binomial mixed, Poisson GEE
  clustered by NPI), since provider-year rows are not independent.
- Time-varying cert-gated classification using the subspecialty certification start-date field,
  assigning URPS only from each physician's certification year onward.
- Workforce entry/exit dynamics, specialty-specific trends, and state-level
  geography.

## [0.1.0] - 2026-04-03

Initial analysis pipeline.

### Added

- Multi-year CMS PUF cache, specialty classification, concentration metrics,
  programmatic abstract, publication tables and figures.
- certification registry linkage splitting OB/GYN into URPS, MIGS and general.
- Study period extended to 2013-2023.
- renv lockfile and the first README.

### Changed

- FPMRS renamed to URPS throughout, following the ABMS subspecialty rename.
