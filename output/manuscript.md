# Specialty Distribution, Procedural Concentration, and Time Trends in Midurethral Sling Surgery Among Medicare Beneficiaries, 2013–2023

Tyler Muffly, MD

> **Revision note (analysis update).** This version reflects the revised analysis:
> (1) URPS combines both training pathways — ABOG (OB/GYN) urogynecologists and
> ABU (urology) urogynecologists cross-referenced from the American Board of
> Urology roster; (2) calendar year 2017 is excluded as a truncated PUF release;
> (3) concentration is reported with both the Gini coefficient and the
> Herfindahl–Hirschman Index (HHI) at the surgeon level; (4) volume differences
> are tested with a repeated-measures model accounting for physicians who recur
> across years; and (5) the specialty-classification choice is examined in a
> sensitivity analysis. Numbers therefore differ from the original submission.

## Abstract

**Objective:** To characterize the specialty distribution, annual procedure volumes, and procedural concentration among physicians performing midurethral sling procedures (CPT 57288) in Medicare beneficiaries.

**Methods:** We analyzed the CMS Medicare Physician and Other Practitioners Public Use File (2013–2023, excluding 2017 as a truncated release). Providers billing CPT 57288 were classified as Urogynecology and Reconstructive Pelvic Surgery (URPS), Minimally Invasive Gynecologic Surgery (MIGS), General OB/GYN, or urology using CMS provider type cross-referenced with the ABOG (OB/GYN pathway) and ABU (urology pathway) subspecialty rosters. Procedural concentration was quantified at the surgeon level using the Gini coefficient and the Herfindahl–Hirschman Index (HHI), overall and per calendar year. Because each physician contributes repeated annual observations, volume differences were modeled with a Poisson generalized estimating equation (GEE) clustered by NPI (adjusted rate ratios, 95% CIs), with a per-physician Kruskal-Wallis secondary analysis. Gynecologic (OB/GYN-trained) market-share trends were assessed by linear regression. Classification was examined under time-varying, modal, and ever-URPS/MIGS schemes.

**Results:** A total of 1,758 unique providers billed CPT 57288, accounting for 131,637 procedures. URPS physicians represented the largest group — 753 providers, 80,033 procedures (60.8%), median 19 procedures/year (IQR 14–29). Urology accounted for 665 providers (34,351 procedures; 26.1%; median 16), General OB/GYN for 330 (16,391; 12.5%; median 15), and MIGS for 10 (862; 0.7%; median 16). In a Poisson GEE clustered by NPI, adjusted annual volume was significantly lower than URPS for every group — Urology (rate ratio 0.82, 95% CI 0.70–0.95), General OB/GYN (0.67, 0.50–0.90), and MIGS (0.56, 0.40–0.76) — with a ~11% decline in 2020 (RR 0.89, 0.85–0.92, p < 0.001) and no overall per-physician time trend (RR 1.00, p = 0.52). Pooled multi-year concentration was lowest for URPS (Gini 0.51, HHI 27; top 20% performed 53.4%) and highest for MIGS (Gini 0.60, HHI 2,919; 68.2%); within-year concentration was low and stable (annual Gini ≈ 0.27; no trend, p = 0.82). The combined gynecologic (OB/GYN-trained) share increased from 60.8% in 2013 to 70.1% in 2023 (slope = 0.84 percentage points/year; p < 0.001), robust across classification schemes (URPS-share slope +0.90 to +0.98 pp/yr, all p ≤ 0.001).

**Conclusions:** URPS physicians perform the majority of midurethral sling procedures in Medicare, with significantly higher adjusted per-physician volume and the most equitable within-group distribution. The rising gynecologic market share reflects attrition of non-URPS providers rather than a more concentrated surgeon pool, with implications for credentialing standards and workforce planning for pelvic floor surgical care.

---

## Introduction

The midurethral sling is the most commonly performed surgical procedure for stress urinary incontinence (SUI) and is considered the gold standard treatment when conservative measures fail.^1,2^ Coded as CPT 57288, the procedure involves placement of a synthetic mesh sling beneath the mid-urethra to restore continence. Despite its central role in pelvic floor surgery, the specialty distribution and procedural concentration among physicians performing this operation in the Medicare population have not been well characterized.

Understanding who performs midurethral slings—and how procedure volume is distributed within each specialty—has direct implications for surgical quality, training requirements, and workforce planning. The volume-outcome relationship in surgery is well established: higher-volume surgeons and hospitals tend to achieve better patient outcomes across a range of procedures.^3,4^ However, the evidence base for volume thresholds in midurethral sling surgery specifically is limited, and the specialty landscape has evolved considerably over the past decade.

Several trends make this analysis timely. First, the subspecialty of Female Pelvic Medicine and Reconstructive Surgery—recently renamed Urogynecology and Reconstructive Pelvic Surgery (URPS)—has grown substantially since achieving American Board of Medical Specialties (ABMS) recognition in 2013,^5^ and is certifiable through both obstetrics-gynecology (ABOG) and urology (ABU) training pathways. Second, the US Food and Drug Administration's reclassification of urogynecologic surgical mesh as a Class III device in 2016 and subsequent market withdrawal orders may have shifted the procedural landscape.^6^ Third, there is growing interest in procedural concentration—the degree to which a small number of providers account for a disproportionate share of procedures—as a metric relevant to quality improvement and resource allocation.^7^

The objective of this study was to characterize the specialty distribution, annual procedure volumes, and procedural concentration among physicians performing midurethral sling procedures in Medicare beneficiaries from 2013 to 2023, and to assess time trends in the gynecologic share of sling procedures.

## Methods

### Study Design and Data Source

We conducted a repeated cross-sectional analysis of the Centers for Medicare & Medicaid Services (CMS) Medicare Physician and Other Practitioners Public Use File (PUF) from 2013 to 2023. This dataset contains 100% of fee-for-service Medicare Part B claims aggregated to the provider-service level, with one row per unique combination of National Provider Identifier (NPI), Healthcare Common Procedure Coding System (HCPCS) code, and place of service per calendar year. The dataset is publicly available and contains no protected health information; institutional review board approval was not required.

The 2017 file was excluded from all analyses as a truncated release: it is roughly half the size of adjacent-year files (1.5 GB vs ~2.7 GB) and contains only 376 sling provider-year records versus ~660–810 in neighboring years, producing an artifactual dip that would bias temporal trends.

### Specialty Classification

Providers were classified into four mutually exclusive groups. CMS-reported provider type (Rndrng_Prvdr_Type, which can vary by year) established a baseline of OB/GYN, urology, or other; providers billing CPT 57288 with a non-OB/GYN, non-urology CMS type not found in the ABOG registry were reclassified as urology. OB/GYN providers were then subdivided using the ABOG subspecialty registry: "Female Pelvic Medicine and Reconstructive Surgery" → URPS, "MIG" → MIGS, all others → General OB/GYN. Finally, urology-pathway urogynecologists were identified from the American Board of Urology (ABU) roster and folded into a single combined URPS group, leaving urology as non-URPS urology; without this step these fellowship-trained urogynecologists appear only as "Urology" in the PUF. Records from non-OB/GYN, non-urology surgical types too heterogeneous to interpret were excluded.

Because the primary conclusion concerns changes in specialty market share, we compared four classification schemes in a sensitivity analysis: modal (single most-frequent specialty per physician), ever-URPS/MIGS (URPS if ever URPS, else MIGS if ever MIGS, else modal), time-varying by CMS provider type, and a fully time-varying, certification-gated scheme in which each physician counts as URPS or MIGS only from their ABOG subspecialty certification year onward (using the ABOG subspecialty certification date, `sub1startdate`) and is otherwise classified by CMS provider type; urology-pathway URPS were held fixed as no urology-subspecialty certification date was available.

### CMS Data Suppression

CMS suppresses provider-service level data when a provider serves fewer than 11 Medicare beneficiaries for a given HCPCS code in a calendar year. All providers in our dataset therefore performed at least 11 midurethral slings per year; the true number of low-volume providers is unknowable. This left-truncation means the concentration metrics reported here are lower bounds.

### Outcome Measures and Statistical Analysis

The primary outcome was the annual midurethral sling count per provider. Procedural concentration was quantified with two complementary **surgeon-level** measures — the Gini coefficient (inequality across the whole surgeon-volume distribution) and the Herfindahl–Hirschman Index (HHI, sum of squared per-surgeon shares on a 0–10,000 scale, driven especially by the largest-volume surgeons) — computed on aggregate provider totals and separately for each calendar year. Each physician is the operative production unit; this is surgeon-level procedural concentration and not the antitrust use of HHI for hospital/health-system market competition, so values are not comparable to FTC/DOJ thresholds.

Because each physician contributes up to ten annual observations, provider-year records are not independent, and rank tests over them are descriptive only. We therefore modeled the annual count with a Poisson generalized estimating equation (GEE) clustered by NPI (exchangeable working correlation, robust standard errors), with fixed effects for specialty (reference URPS), calendar year, specialty × year, and a 2020 (COVID) indicator, reporting adjusted rate ratios with 95% CIs; a negative-binomial mixed model with a random intercept per NPI gave concordant estimates. As a secondary analysis restoring independence, we compared one value per physician (each physician's median annual volume) across specialties by Kruskal-Wallis and Bonferroni-adjusted pairwise Wilcoxon tests. Time trends in the gynecologic (OB/GYN-residency-trained: ABOG-URPS + MIGS + General OB/GYN) share were assessed by ordinary least-squares regression on calendar year.

All analyses were performed in R 4.4 with package versions locked via renv. The complete pipeline is available at https://github.com/mufflyt/sling-volume-patterns.

## Results

### Overall Volume and Specialty Distribution

A total of 1,758 unique providers billed CPT 57288, accounting for 131,637 procedures (Table 1). URPS physicians constituted the largest group — 753 providers, 80,033 procedures (60.8%) — followed by non-URPS urology (665 providers; 34,351; 26.1%), General OB/GYN (330; 16,391; 12.5%), and MIGS (10; 862; 0.7%). Folding urology-pathway urogynecologists into URPS moved 150 providers (11,503 procedures) from urology to URPS relative to an ABOG-only classification.

### Procedure Volume by Specialty

URPS providers had the highest median annual volume at 19 procedures/year (IQR 14–29), versus 16 for urology, 15 for General OB/GYN, and 16 for MIGS. In the Poisson GEE clustered by NPI, adjusted annual volume relative to URPS was significantly lower for every other group: urology rate ratio (RR) 0.82 (95% CI 0.70–0.95, p = 0.008), General OB/GYN 0.67 (0.50–0.90, p = 0.008), and MIGS 0.56 (0.40–0.76, p < 0.001) (Table 3). Volume dropped ~11% in 2020 (RR 0.89, 0.85–0.92, p < 0.001), consistent with the COVID-19 pandemic, and there was no overall linear per-physician time trend (year RR 1.00, 0.99–1.00, p = 0.52). The secondary one-value-per-physician analysis agreed (Kruskal-Wallis H = 66.1, df = 3, p < 0.001; URPS significantly exceeded urology and General OB/GYN, pairwise p < 0.001; URPS vs MIGS not significant, n = 10).

### Procedural Concentration

Pooled multi-year concentration was lowest for URPS (Gini 0.51, HHI 27; top 20% performed 53.4%) and rose through urology (Gini 0.52, HHI 35; 57.5%), General OB/GYN (Gini 0.55, HHI 89; 60.8%), and MIGS (Gini 0.60, HHI 2,919; 68.2%) (Table 2). Gini and HHI ranked the specialties identically, but for the three main groups HHI was very low in absolute terms (27–89 of 10,000): sling volume is spread unevenly across many surgeons rather than dominated by a few. The high MIGS HHI reflects its 10 providers and should not be over-interpreted. Computed separately for each year, within-year concentration was modest and stable across the study period (pooled annual Gini 0.26–0.28; no trend, slope ≈ 0.000/year, p = 0.82), indicating that midurethral sling care did not become concentrated among a shrinking set of high-volume surgeons even as the workforce contracted.

### Time Trends in Market Share

The combined gynecologic (OB/GYN-trained) share of sling procedures increased from 60.8% in 2013 to 70.1% in 2023 (slope = 0.84 percentage points/year; p < 0.001; Figure 1), while non-URPS urology fell from 30.7% to 23.1%. The combined-URPS share rose from 53.4% to 63.8% (+0.90 pp/year, p < 0.001). This trend was robust to classification scheme, and directional under all: the URPS-share slope was +0.90 to +0.98 pp/year (all p ≤ 0.001) under the modal, ever-URPS/MIGS, and CMS-provider-type time-varying schemes. Under the fully certification-gated time-varying scheme — in which the 45% of URPS physicians certified after 2013 count as General OB/GYN or urology in their pre-certification years — the rise was substantially steeper: URPS share increased from 46.3% in 2013 to 74.2% in 2023 (slope = 2.28 pp/year; p < 0.001), and the gynecologic share slope rose to 1.33 pp/year (p < 0.001). Fixed-membership classification therefore understates the true growth of the certified URPS workforce's market share.

The number of observable surgeons fell over the period, driven by non-URPS providers: urology declined from 282 to 144 (−12.6/year, p = 0.002) and General OB/GYN from 142 to 76 (−6.9/year, p = 0.002), whereas the URPS surgeon count was statistically stable (385 to 338; −6.4/year, p = 0.10). Because per-physician volume showed no time trend, the rising URPS share reflects attrition of non-URPS providers rather than growth in the URPS workforce.

## Discussion

This national analysis of Medicare claims from 2013 to 2023 shows that URPS physicians perform the majority of midurethral sling procedures (60.8%), with the highest adjusted per-physician volume and the most equitable within-group distribution. The combined gynecologic share increased significantly over the decade, from 60.8% to 70.1%.

### Subspecialty Dominance and Both Training Pathways

A key methodological contribution is the identification of urogynecologists through **both** certifying pathways — ABOG (OB/GYN) and ABU (urology). Cross-referencing the ABU roster reassigned 150 urology-typed providers (8.2% of all slings) to URPS, sharpening the finding that midurethral sling surgery in Medicare is predominantly performed by fellowship-trained urogynecologists. The finding is robust: the pooled URPS Gini changed negligibly (0.51 → 0.52) under the reclassification.

### Procedural Concentration

Reporting the Gini coefficient and HHI together makes the concentration finding difficult to attribute to a single metric: the two answer related but distinct questions and agree here. The low absolute HHI for the three main groups (27–89) shows that, although volume is unequally distributed (Gini 0.51–0.55), no individual surgeon approaches a dominant share — this is inequality across many surgeons, not domination by a few. Reporting each physician as the production unit follows workforce-concentration analyses in other surgical specialties; it is explicitly a surgeon-level, not a market-competition, measure.

### Temporal Trends and Workforce Implications

The repeated-measures model clarifies the mechanism behind the rising gynecologic share. Individual physician volume did not change over time (year RR 1.00), but the number of non-URPS surgeons fell sharply while URPS numbers held steady. The market-share shift is therefore a workforce-composition change — non-URPS attrition — rather than a change in how much any individual operates. The significant 2020 decline (RR 0.89) is consistent with pandemic-related deferral of elective surgery and was robust to excluding 2020.

### Limitations

Several limitations warrant discussion. First, CMS suppresses provider-level data below 11 beneficiaries, so the lowest-volume providers are unobserved and reported concentration is a lower bound. Second, the PUF captures only fee-for-service Medicare Part B; younger, Medicare Advantage, Medicaid, commercially insured, and uninsured patients are not represented. Third, specialty classification depends on CMS provider type and the ABOG/ABU rosters; providers who completed URPS fellowship but are not board-certified would be misclassified. Fourth, subspecialty classification relied on the ABOG subspecialty certification date (`sub1startdate`); a small fraction of URPS providers (~8%) could not be matched to a certification year and were held fixed, and urology-pathway URPS were held fixed because no urology-subspecialty certification date was available. The certification-gated time-varying result should therefore be read as a lower bound on the true steepness of the URPS market-share increase. Fifth, the exclusion of 2017 removes one year of the time series (the underlying file being truncated); re-running with a complete 2017 file would restore all 11 years. Sixth, Tot_Srvcs may include bilateral or modifier-inflated services.

### Strengths

This study uses a national, 100% sample of Medicare fee-for-service claims; identifies urogynecologists through both training pathways; reports concentration with two complementary surgeon-level measures at both the pooled and annual level; accounts for the non-independence of repeated physician-year observations with a clustered model; and is fully reproducible.

## Conclusions

In this national Medicare cohort, URPS physicians perform the majority of midurethral slings with the highest adjusted per-physician volume and the most equitable within-group distribution. The growing gynecologic market share is driven by attrition of non-URPS providers rather than by increasing surgeon-level concentration, with implications for training requirements, credentialing standards, and access to pelvic floor surgical care.

## References

1. Ford AA, Rogerson L, Cody JD, Aluko P, Ogah JA. Mid-urethral sling operations for stress urinary incontinence in women. Cochrane Database Syst Rev. 2017;7(7):CD006375.

2. Kobashi KC, Albo ME, Dmochowski RR, et al. Surgical treatment of female stress urinary incontinence: AUA/SUFU guideline. J Urol. 2017;198(4):875-883.

3. Birkmeyer JD, Stukel TA, Siewers AE, Goodney PP, Wennberg DE, Lucas FL. Surgeon volume and operative mortality in the United States. N Engl J Med. 2003;349(22):2117-2127.

4. Reames BN, Ghaferi AA, Birkmeyer JD, Dimick JB. Hospital volume and operative mortality in the modern era. Ann Surg. 2014;260(2):244-251.

5. American Board of Medical Specialties. ABMS announces approval of new subspecialty certificate in female pelvic medicine and reconstructive surgery. 2011. Available at: https://www.abms.org.

6. US Food and Drug Administration. FDA takes action to protect women's health, orders manufacturers of surgical mesh intended for transvaginal repair of pelvic organ prolapse to stop selling all devices. April 16, 2019. Available at: https://www.fda.gov.

7. Stitzenberg KB, Sigurdson ER, Egleston BL, Starkey RB, Meropol NJ. Centralization of cancer surgery: implications for patient access to optimal care. J Clin Oncol. 2009;27(28):4671-4678.

---

## Tables

**Table 1.** Specialty distribution of CPT 57288 providers, Medicare PUF 2013–2023 (2017 excluded; combined URPS).

| Specialty | N providers | Total slings | % of all slings | Median annual volume (IQR) |
|-----------|-------------|-------------|-----------------|---------------------------|
| URPS | 753 | 80,033 | 60.8% | 19 (14–29) |
| Urology (non-URPS) | 665 | 34,351 | 26.1% | 16 (13–22) |
| General OB/GYN | 330 | 16,391 | 12.5% | 15 (12–22) |
| MIGS | 10 | 862 | 0.7% | 16 (12–23) |
| **Total** | **1,758** | **131,637** | **100%** | — |

**Table 2.** Procedural concentration by specialty (aggregate provider-level volumes): Gini and HHI (surgeon-level).

| Specialty | N providers | Gini | HHI (0–10,000) | % by top 10% | % by top 20% |
|-----------|-------------|------|----------------|--------------|--------------|
| URPS | 753 | 0.51 | 27 | 34.3% | 53.4% |
| Urology (non-URPS) | 665 | 0.52 | 35 | 38.5% | 57.5% |
| General OB/GYN | 330 | 0.55 | 89 | 43.2% | 60.8% |
| MIGS | 10 | 0.60 | 2,919 | 48.4% | 68.2% |

**Table 3.** Repeated-measures model of annual sling volume — adjusted rate ratios from a Poisson GEE clustered by NPI (reference URPS; exchangeable correlation, robust SEs).

| Term | Rate ratio (95% CI) | p-value |
|------|--------------------|---------|
| Urology (vs URPS) | 0.82 (0.70–0.95) | 0.008 |
| General OB/GYN (vs URPS) | 0.67 (0.50–0.90) | 0.008 |
| MIGS (vs URPS) | 0.56 (0.40–0.76) | < 0.001 |
| Calendar year (per year) | 1.00 (0.99–1.00) | 0.52 |
| 2020 (COVID) indicator | 0.89 (0.85–0.92) | < 0.001 |

**Table 4.** Gynecologic (OB/GYN-trained) market-share trend and classification-scheme sensitivity.

| Analysis | 2013 → 2023 | Slope (pp/year) | p-value |
|----------|-------------|-----------------|---------|
| Gynecologic (ABOG-URPS + MIGS + Gen OB/GYN) share | 60.8% → 70.1% | 0.84 | < 0.001 |
| Combined URPS share | 53.4% → 63.8% | 0.90 | < 0.001 |
| URPS share — modal scheme | — | 0.98 | < 0.001 |
| URPS share — ever-URPS/MIGS scheme | — | 0.96 | 0.001 |
| URPS share — time-varying cert-gated (ABOG sub1startdate) | 46.3% → 74.2% | 2.28 | < 0.001 |

---

## Figures

**Figure 1.** Market share of midurethral sling procedures (CPT 57288) by specialty group, Medicare PUF 2013–2023 (2017 excluded). The combined gynecologic (OB/GYN-trained) share increased from 60.8% to 70.1% (slope 0.84 pp/year; p < 0.001).

**Figure 2.** Distribution of annual midurethral sling volume by specialty group (violin + box plots, log scale). The minimum observable volume is 11 due to CMS cell suppression.

**Figure 3.** Lorenz curves of procedural concentration by specialty. Curves farther from the diagonal indicate greater concentration; URPS (Gini 0.51) is closest to equality, MIGS (0.60) farthest.

**Figure 4.** Annual procedural concentration by specialty (Gini, HHI, top-20% and bottom-50% shares) per calendar year; within-year concentration is low and stable. MIGS excluded from these panels (too few surgeons/year for a stable estimate).

**Figure 5.** Observable surgeons and total procedure volume per year by specialty; the surgeon-pool decline is concentrated in urology and General OB/GYN.
