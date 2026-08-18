# STROBE Statement

Checklist of items that should be included in reports of **cross-sectional studies**.

**Manuscript:** Specialty Distribution and Surgeon-Level Concentration of Sling
Surgery for Stress Urinary Incontinence in Fee-for-Service Medicare, 2013-2023

**Author:** Tyler Muffly, MD

Reference: von Elm E, Altman DG, Egger M, Pocock SJ, Gøtzsche PC, Vandenbroucke JP;
STROBE Initiative. The Strengthening the Reporting of Observational Studies in
Epidemiology (STROBE) statement: guidelines for reporting observational studies.
*Ann Intern Med.* 2007;147(8):573-577. <https://www.strobe-statement.org/>

> **Before submitting:** the Page/Line column is intentionally blank. Fill it from
> the final rendered `manuscript.docx`, which carries continuous line numbers.
> Section names below are stable; page and line numbers are not, because they
> shift whenever the text is re-rendered.

---

## Title and abstract

| # | Recommendation | Where addressed | Page/Line |
|---|---|---|---|
| 1a | Indicate the study's design with a commonly used term in the title or the abstract | **Abstract, Methods:** "We analyzed all 11 annual CMS Medicare Physician and Other Practitioners Public Use Files." **Materials and Methods, Study Design:** "repeated cross-sectional analysis". *Note: the title names the data source and period but not the design; the design term appears in the abstract and Methods.* | |
| 1b | Provide in the abstract an informative and balanced summary of what was done and what was found | **Abstract**, structured as Objectives / Methods / Results / Conclusions, 302 words. Conclusions explicitly bound the claim: "These findings describe claims-visible service patterns, not the complete national surgical workforce." | |

## Introduction

| # | Recommendation | Where addressed | Page/Line |
|---|---|---|---|
| 2 | Explain the scientific background and rationale for the investigation being reported | **Introduction**, paragraphs 1-3: procedure definition and CPT 57288 scope, the volume-outcome literature, and three developments motivating timing (URPS subspecialty certification from 2013, FDA mesh actions, and interest in procedural distribution). | |
| 3 | State specific objectives, including any prespecified hypotheses | **Introduction**, final paragraph: "We therefore examined specialty distribution, annual clinician volume, and surgeon-level concentration ... We also evaluated changes in each specialty's share of observable services." *Note: objectives are stated; no formal prespecified hypotheses, consistent with a descriptive health-services design.* | |

## Methods

| # | Recommendation | Where addressed | Page/Line |
|---|---|---|---|
| 4 | Present key elements of study design early in the paper | **Materials and Methods > Study Design and Data Source**, first sentence. | |
| 5 | Describe the setting, locations, and relevant dates, including periods of recruitment, exposure, follow-up, and data collection | **Study Design and Data Source:** national fee-for-service Medicare Part B, all 11 annual PUF releases 2013 through 2023, verified against CMS file specifications. | |
| 6a | Give the eligibility criteria, and the sources and methods of selection of participants | **Specialty Classification** (full section) and **Figure 5, classification flow**: all NPIs billing CPT 57288; organizational NPIs (NPPES entity type 2) and unclassifiable individual billers excluded from the primary cohort. | |
| 6b | *Cohort studies only:* matched studies, matching criteria and number of exposed/unexposed | **Not applicable** (cross-sectional design). | |
| 7 | Clearly define all outcomes, exposures, predictors, potential confounders, and effect modifiers | **Outcome Measures and Statistical Analysis:** primary outcome is annual reported CPT 57288 services per provider (`Tot_Srvcs`); specialty group is the primary predictor; calendar year, specialty-by-year interaction and a 2020 indicator are covariates. | |
| 8 | For each variable of interest, give sources of data and details of methods of assessment. Describe comparability of assessment methods if there is more than one group | **Specialty Classification:** annual CMS rendering-provider type, ABOG registry (including `sub1startdate` for certification year), ABU roster; linkage by exact NPI, then by full name and practice state where necessary. Denominator from CMS Program Statistics, table MDCR ENROLL AB 11. | |
| 9 | Describe any efforts to address potential sources of bias | **CMS Data Suppression** (entire section) is the central bias discussion: cells under 11 beneficiaries are suppressed, so low-volume surgeons are systematically invisible and full-market concentration is not identified. Mitigations: bootstrap confidence intervals, plus a sensitivity analysis adding hypothetical suppressed low-volume providers (Supplementary Table S8). Classification bias addressed by the two opposing scenarios (fixed membership vs certification-gated) and by modal and ever-URPS/MIGS sensitivity analyses. | |
| 10 | Explain how the study size was arrived at | **Study Design and Data Source** and **Results > Cohort and Annual Volume**. *Note: no sample-size calculation was performed or is applicable. The study analyzes the complete set of observable CPT 57288 billers in the national PUF for 2013-2023, so study size is determined by the data source rather than chosen.* | |
| 11 | Explain how quantitative variables were handled in the analyses. If applicable, describe which groupings were chosen and why | **Outcome Measures and Statistical Analysis:** service counts modeled on the count scale with log enrollment offset; calendar year centered at 2018; volume summarized as median with p25-p75 because distributions are right-skewed. **Specialty Classification** explains the five-group taxonomy and why URPS is split by certification pathway. | |
| 12a | Describe all statistical methods, including those used to control for confounding | **Outcome Measures and Statistical Analysis:** Poisson GEE clustered by NPI with exchangeable working correlation and robust standard errors; quasibinomial GLM for market share; Kruskal-Wallis with Bonferroni-adjusted pairwise Wilcoxon as a one-observation-per-physician secondary. | |
| 12b | Describe any methods used to examine subgroups and interactions | **Outcome Measures and Statistical Analysis:** specialty-by-year interactions with specialty-specific trends reported as marginal contrasts; separate OLS regressions of each specialty's annual share, presented descriptively. | |
| 12c | Explain how missing data were addressed | **CMS Data Suppression:** missingness here is structural rather than random. Records below the 11-beneficiary threshold are absent by design and cannot be imputed, which is stated explicitly as a limit on identification rather than handled by imputation. | |
| 12d | *Cross-sectional studies:* if applicable, describe analytical methods taking account of sampling strategy | **Not applicable.** The PUF is a complete enumeration of observable fee-for-service billers, not a sample, so no survey weights or sampling design apply. Non-independence of repeated physician-year observations is handled by clustering on NPI. | |
| 12e | Describe any sensitivity analyses | **Outcome Measures and Statistical Analysis** and **Specialty Classification:** negative-binomial mixed model with NPI random intercept; analysis excluding 2020; restriction to clinicians observable in at least two years; four classification schemes (fixed, certification-gated, modal, ever-URPS/MIGS); three handlings of ambiguous billers (Supplementary Table S11); suppressed-provider concentration illustration (Supplementary Table S8). | |

## Results

| # | Recommendation | Where addressed | Page/Line |
|---|---|---|---|
| 13a | Report numbers of individuals at each stage of the study | **Results > Cohort and Annual Volume**, and **Figure 5** (classification flow), which reports billers identified, organizational NPIs excluded, unclassifiable billers set aside, and the final five-group cohort. | |
| 13b | Give reasons for non-participation at each stage | **Specialty Classification:** organizational NPIs excluded as billing entities rather than clinicians; remaining unclassifiable individual billers could not be confirmed as either specialty. | |
| 13c | Consider use of a flow diagram | **Figure 5**, specialty classification flow. | |
| 14a | Give characteristics of study participants and information on exposures and potential confounders | **Table 1** (specialty distribution, physician counts, services, shares, median annual volume) and **Results > Cohort and Annual Volume** (persistence: proportions observable in 1, 2-5, 6-10, and all 11 years). | |
| 14b | Indicate number of participants with missing data for each variable of interest | **CMS Data Suppression.** *Note: the number of suppressed clinicians is unknowable by construction, which is stated rather than estimated. Supplementary Table S8 illustrates the effect of hypothetical suppressed providers without claiming to estimate their number.* | |
| 15 | *Cross-sectional studies:* report numbers of outcome events or summary measures | **Table 1** and **Results > Specialty Distribution and Trends**: services by group with shares and medians. **Table 2**: concentration measures. | |
| 16a | Give unadjusted estimates and, if applicable, confounder-adjusted estimates and their precision. Make clear which confounders were adjusted for and why included | **Results > Specialty Distribution and Trends** and **Surgeon Volume and Concentration**; adjusted rate ratios with 95% confidence intervals from the Poisson GEE, with year centered at 2018 and a 2020 indicator. Unadjusted descriptive medians appear in Table 1. | |
| 16b | Report category boundaries when continuous variables were categorized | **Results > Cohort and Annual Volume** (persistence categories 1, 2-5, 6-10, 11 years) and **Outcome Measures** (two-year washout defining newly observable, continuing, and no longer observable). | |
| 16c | If relevant, consider translating estimates of relative risk into absolute risk for a meaningful time period | **Results > Cohort and Annual Volume:** the enrollment-adjusted rate ratio is translated into an approximate decade-level percentage change, and observable services are expressed per 100,000 female Part B fee-for-service beneficiaries. | |
| 17 | Report other analyses done, such as analyses of subgroups and interactions, and sensitivity analyses | **Results > Observable Participation Over Time**; the geographic analysis; and Supplementary Tables S8 through S13 covering classification sensitivity, model sensitivity, workforce dynamics and state-level distribution. | |

## Discussion

| # | Recommendation | Where addressed | Page/Line |
|---|---|---|---|
| 18 | Summarise key results with reference to study objectives | **Discussion**, opening paragraph, and **Conclusions**. | |
| 19 | Discuss limitations of the study, taking into account sources of potential bias or imprecision. Discuss both direction and magnitude of any potential bias | **Discussion > Limitations** (dedicated section). Covers CMS suppression and its direction (true concentration likely higher than observed), fee-for-service-only coverage with Medicare Advantage migration, absence of outcome data, crude non-age-standardized rates, classification uncertainty, and the descriptive status of MIGS given only 10 physicians. | |
| 20 | Give a cautious overall interpretation of results considering objectives, limitations, multiplicity of analyses, results from similar studies, and other relevant evidence | **Discussion > Specialty Distribution in Context**, **Procedural Concentration and the Volume-Outcome Relationship**, and **Temporal Trends and the Evolving SUI Landscape**, which situate findings against 20 cited references. | |
| 21 | Discuss the generalisability (external validity) of the study results | **Discussion > Limitations** and **Conclusions:** findings describe observable fee-for-service Medicare, explicitly not the complete national sling market, and not commercially insured or Medicare Advantage populations. | |

## Other information

| # | Recommendation | Where addressed | Page/Line |
|---|---|---|---|
| 22 | Give the source of funding and the role of the funders for the present study and, if applicable, for the original study on which the present article is based | **Title page, Funding.** ⚠️ **TO COMPLETE BEFORE SUBMISSION.** This is currently a placeholder. State the funding source, or state "None", and describe the funder's role if any. | |

---

## Items requiring action before submission

1. **Item 22, Funding** is a placeholder on the title page and must be completed.
   The same is true of affiliation, corresponding-author contact details,
   conflicts of interest, and acknowledgments, which STROBE does not cover but
   the journal requires.
2. **Page and line numbers** throughout this checklist are blank by design.
   Fill them from the final rendered `manuscript.docx`.
3. **Item 1a**: the design term "cross-sectional" appears in the abstract and
   Methods but not in the title. This satisfies the item as written, which
   permits either location, but some editors prefer it in the title.

## Items deliberately marked not applicable

- **6b** (matching): cross-sectional design, no matching.
- **12d** (sampling strategy): the PUF is a complete enumeration of observable
  billers rather than a sample, so no sampling weights apply. Non-independence
  of repeated physician-year observations is instead handled by clustering on
  NPI.

An explanation and elaboration article discusses each checklist item and gives
methodological background and published examples of transparent reporting.
The STROBE checklist is best used in conjunction with that article, which is
freely available at <https://www.strobe-statement.org/>.
