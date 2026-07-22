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

**Methods:** We analyzed the CMS Medicare Physician and Other Practitioners Public Use File (2013–2023, excluding 2017 as a truncated release). Providers billing CPT 57288 were classified as Urogynecology and Reconstructive Pelvic Surgery (URPS), Minimally Invasive Gynecologic Surgery (MIGS), General OB/GYN, or urology using CMS provider type cross-referenced with the ABOG (OB/GYN pathway) and ABU (urology pathway) subspecialty rosters. Procedural concentration was quantified at the surgeon level using the Gini coefficient and the Herfindahl–Hirschman Index (HHI), overall and per calendar year. Because each physician contributes repeated annual observations, volume differences were modeled with a Poisson generalized estimating equation (GEE) clustered by NPI (adjusted rate ratios, 95% CIs), with a per-physician Kruskal-Wallis secondary analysis. The market-share trend was reported under multiple classification schemes that bracket the truth: fixed-membership (each physician's eventual subspecialty applied to all years; a lower bound) and time-varying certification-gated (URPS/MIGS only from the ABOG subspecialty certification year; an upper bound, since certification lags practice onset), with modal and ever-URPS/MIGS as additional sensitivity analyses.

**Results:** A total of 1,745 unique physicians billed CPT 57288 (131,637 procedures; 6,202 physician-years) after excluding the truncated 2017 file. URPS physicians represented the largest group — 753 physicians, 80,033 procedures (60.8%), median 19 procedures/year (p25–p75, 14–27) — followed by non-URPS urology (665 physicians; 26.1%; median 16), General OB/GYN (330; 12.5%; median 15), and MIGS (10; 0.7%; median 16). Observed annual procedures declined (16,399 in 2013 to 12,223 in 2023; −469/year, p = 0.03), reaching a low in 2020 (9,228) with partial recovery. In a Poisson GEE clustered by NPI, adjusted annual volume was significantly lower than URPS for every group — urology (rate ratio 0.82, 95% CI 0.70–0.95), General OB/GYN (0.67, 0.50–0.90), and MIGS (0.56, 0.40–0.76) — with a ~11% decline in 2020 (RR 0.89, 0.85–0.92, p < 0.001) and no overall per-physician time trend (RR 1.00, p = 0.52). Among the three well-populated groups, pooled multi-year concentration was modest and lowest for URPS (Gini 0.51, HHI 27; top 20% performed 53.4%); within-year concentration was low and stable (annual Gini ≈ 0.27; no trend, p = 0.82). MIGS (n = 10) is reported descriptively. Modeled by specialty, URPS share rose (+0.90 pp/year, p < 0.001) while urology (−0.55, p = 0.004) and General OB/GYN (−0.42, p = 0.006) declined; the combined URPS increase was significant under every classification scheme, bracketed by fixed-membership classification (lower bound: gynecologic share 60.8% → 70.1%, +0.84 pp/year) and time-varying certification-gated classification (upper bound, as certification lags practice onset: URPS share 46.3% → 74.2%, +2.28 pp/year). Newly observable entrant surgeons (absent the prior two observable years) performed 7–23% of annual volume at low median volume (~13); URPS contributed the most entrants (440 over the period) while urology showed substantial churn (373 entrants despite a declining share).

**Conclusions:** URPS physicians perform the majority of midurethral sling procedures in Medicare, with significantly higher adjusted per-physician volume and the most equitable within-group distribution. The rising gynecologic market share reflects attrition of non-URPS providers rather than a more concentrated surgeon pool, with implications for credentialing standards and workforce planning for pelvic floor surgical care.

---

## Introduction

The midurethral sling is the most commonly performed surgical procedure for stress urinary incontinence (SUI) and is considered the gold standard treatment when conservative measures fail.^1,2^ Coded as CPT 57288, the procedure involves placement of a synthetic mesh sling beneath the mid-urethra to restore continence. Despite its central role in pelvic floor surgery, the specialty distribution and procedural concentration among physicians performing this operation in the Medicare population have not been well characterized.

Understanding who performs midurethral slings—and how procedure volume is distributed within each specialty—has direct implications for surgical quality, training requirements, and workforce planning. The volume-outcome relationship in surgery is well established: higher-volume surgeons and hospitals tend to achieve better patient outcomes across a range of procedures.^4,5^ However, the evidence base for volume thresholds in midurethral sling surgery specifically is limited, and the specialty landscape has evolved considerably over the past decade.

Several trends make this analysis timely. First, the subspecialty of Female Pelvic Medicine and Reconstructive Surgery—recently renamed Urogynecology and Reconstructive Pelvic Surgery (URPS)—has grown substantially since achieving American Board of Medical Specialties (ABMS) recognition in 2013,^6^ and is certifiable through both obstetrics-gynecology (ABOG) and urology (ABU) training pathways. Second, the US Food and Drug Administration's actions on urogynecologic surgical mesh, culminating in the 2019 order to stop selling transvaginal mesh for prolapse, reshaped public perception and may have shifted the procedural landscape for slings.^7^ Third, there is growing interest in procedural concentration—the degree to which a small number of providers account for a disproportionate share of procedures—as a metric relevant to quality improvement and resource allocation.^8^

The objective of this study was to characterize the specialty distribution, annual procedure volumes, and procedural concentration among physicians performing midurethral sling procedures in Medicare beneficiaries from 2013 to 2023, and to assess time trends in the gynecologic share of sling procedures.

## Methods

### Study Design and Data Source

We conducted a repeated cross-sectional analysis of the Centers for Medicare & Medicaid Services (CMS) Medicare Physician and Other Practitioners Public Use File (PUF) from 2013 to 2023. This dataset contains 100% of fee-for-service Medicare Part B claims aggregated to the provider-service level, with one row per unique combination of National Provider Identifier (NPI), Healthcare Common Procedure Coding System (HCPCS) code, and place of service per calendar year. The dataset is publicly available and contains no protected health information; institutional review board approval was not required.

The 2017 file was excluded from all analyses as a truncated release: it is roughly half the size of adjacent-year files (1.5 GB vs ~2.7 GB) and contains only 376 sling provider-year records versus ~660–810 in neighboring years, producing an artifactual dip that would bias temporal trends.

### Specialty Classification

Providers were classified into four mutually exclusive groups. CMS-reported provider type (Rndrng_Prvdr_Type, which can vary by year) established a baseline of OB/GYN, urology, or other; providers billing CPT 57288 with a non-OB/GYN, non-urology CMS type not found in the ABOG registry were reclassified as urology. OB/GYN providers were then subdivided using the ABOG subspecialty registry: "Female Pelvic Medicine and Reconstructive Surgery" → URPS, "MIG" → MIGS, all others → General OB/GYN. Finally, urology-pathway urogynecologists were identified from the American Board of Urology (ABU) roster and folded into a single combined URPS group, leaving urology as non-URPS urology; without this step these fellowship-trained urogynecologists appear only as "Urology" in the PUF. Records from non-OB/GYN, non-urology surgical types too heterogeneous to interpret were excluded.

Because the primary conclusion concerns changes in specialty market share, and because 45% of URPS physicians in this cohort were certified after 2013, we bounded the market-share trend with two classification schemes. **Fixed-membership** classification assigns each physician's eventual subspecialty to all study years; because it treats not-yet-certified physicians as already URPS, it is a lower bound on the rate of increase. **Time-varying, certification-gated** classification counts a physician as URPS or MIGS only from their ABOG subspecialty certification year onward (from `sub1startdate`, which ranges 2013–2024 and is distinct from the initial OB/GYN board date), and classifies earlier years by that year's CMS provider type; because board certification lags the start of subspecialty practice — the 2013 examination certified physicians already practicing urogynecology, and later diplomates practiced before boarding — it misattributes pre-certification practice years and is an upper bound. Modal and ever-URPS/MIGS schemes were additional sensitivity analyses. Urology-pathway URPS were held fixed in all schemes as no urology-subspecialty certification date was available. The whole-period cross-sectional distribution, concentration, and volume analyses (Tables 1–3) assign each physician their eventual (combined) subspecialty.

### CMS Data Suppression

CMS suppresses provider-service level data when a provider serves fewer than 11 Medicare beneficiaries for a given HCPCS code in a calendar year. All providers in our dataset therefore performed at least 11 midurethral slings per year; the true number of low-volume providers is unknowable. This left-truncation means the concentration metrics reported here are lower bounds.

### Outcome Measures and Statistical Analysis

The primary outcome was the annual midurethral sling count per provider. Procedural concentration was quantified with two complementary **surgeon-level** measures — the Gini coefficient (inequality across the whole surgeon-volume distribution) and the Herfindahl–Hirschman Index (HHI, sum of squared per-surgeon shares on a 0–10,000 scale, driven especially by the largest-volume surgeons) — computed on aggregate provider totals and separately for each calendar year. Each physician is the operative production unit; this is surgeon-level procedural concentration and not the antitrust use of HHI for hospital/health-system market competition, so values are not comparable to FTC/DOJ thresholds.

Because each physician contributes up to ten annual observations, provider-year records are not independent, and rank tests over them are descriptive only. We therefore modeled the annual count with a Poisson generalized estimating equation (GEE) clustered by NPI (exchangeable working correlation, robust standard errors), with fixed effects for specialty (reference URPS), calendar year, specialty × year, and a 2020 (COVID) indicator, reporting adjusted rate ratios with 95% CIs; a negative-binomial mixed model with a random intercept per NPI gave concordant estimates. As a secondary analysis restoring independence, we compared one value per physician (each physician's median annual volume) across specialties by Kruskal-Wallis and Bonferroni-adjusted pairwise Wilcoxon tests.

We modeled each specialty's annual market share separately by ordinary least-squares regression of its annual percentage share on calendar year (URPS, urology, and General OB/GYN; MIGS descriptively given n = 10), in addition to the combined gynecologic share.

To characterize workforce turnover, we classified each observable surgeon in each year, using a two-year washout, as an **entrant** (observable that year but absent in both of the two prior observable years), **continuing** (observable and not an entrant), or apparently **exiting** (observable that year but absent in both of the two subsequent observable years), and computed the entrant share of annual volume, median entrant volume, and entrants by specialty. Because CMS suppression removes providers below 11 beneficiaries, we describe these as *newly observable* surgeons rather than definitively new sling surgeons.

As a restrained secondary geographic analysis, we tabulated observable surgeons and the URPS share by provider practice state and identified states with no observable URPS surgeon performing at least 11 Medicare slings in any year. Population-based rates (surgeons and procedures per female Medicare beneficiary) were not computed, as fee-for-service denominators with Medicare Advantage adjustment were outside the scope of this analysis.

All analyses were performed in R 4.4 with package versions locked via renv. The complete pipeline is available at https://github.com/mufflyt/sling-volume-patterns.

## Results

### Cohort and Annual Volume

Across the full 11-year window, 1,761 unique physicians billed CPT 57288, accounting for 139,855 observed services in 6,572 physician-year observations. Excluding the truncated 2017 file, the analytic cohort comprised 1,745 unique physicians, 131,637 procedures, and 6,202 physician-year observations. Most physicians were observed only intermittently: 567 (32%) appeared in a single year, 753 (43%) in 2–5 years, 375 (21%) in 6–10 years, and only 66 (4%) in all 11 years — consistent with a workforce in which a minority sustain a durable Medicare sling practice.

Observed annual procedures declined over the period, from 16,399 in 2013 to 12,223 in 2023 (linear trend −469 procedures/year; p = 0.03), and the number of observable surgeons fell from 812 to 562. Volume reached its low in 2020 (9,228 procedures), consistent with pandemic-related deferral of elective surgery, and partially recovered thereafter (12,053 in 2022; 12,223 in 2023) without returning to pre-2020 levels. A single pooled total would obscure this decline: Medicare sling volume fell over the decade even as its specialty composition shifted.

### Specialty Distribution and Trends

URPS physicians constituted the largest group — 753 physicians, 3,498 physician-years, 80,033 procedures (60.8%), median 19 procedures/year (p25–p75, 14–27) — followed by non-URPS urology (665 physicians; 1,810 physician-years; 34,351 procedures; 26.1%; median 16, 13–22), General OB/GYN (330; 858; 16,391; 12.5%; median 15, 12–22), and MIGS (10; 36; 862; 0.7%; median 16, 12–24) (Table 1). Per-specialty physician counts sum to slightly more than the unique total because 13 physicians changed specialty group across years. Folding urology-pathway urogynecologists into URPS moved 150 physicians (11,503 procedures) from urology relative to an ABOG-only classification.

Modeled separately, each specialty's annual market share moved significantly and in divergent directions (Table 1): URPS rose from 53.4% (2013) to 63.8% (2023) (+0.90 percentage points/year; 95% CI 0.49 to 1.31; p < 0.001), whereas urology fell from 30.7% to 23.1% (−0.55; 95% CI −0.87 to −0.23; p = 0.004) and General OB/GYN from 15.7% to 12.3% (−0.42; 95% CI −0.68 to −0.16; p = 0.006). MIGS rose descriptively from 0.2% to 0.8% (+0.07/year; n = 10, interpreted with caution). Because total observed volume fell, these are shifts in specialty ownership rather than differential growth. The combined-URPS increase was significant under all classification schemes and bounded by fixed membership (lower bound; gynecologic share 60.8% → 70.1%, +0.84 pp/year) and time-varying certification-gating (upper bound; URPS share 46.3% → 74.2%, +2.28 pp/year, as certification lags practice onset — Table 4).

In the Poisson GEE clustered by NPI, adjusted annual volume relative to URPS was significantly lower for every other group — urology rate ratio 0.82 (95% CI 0.70–0.95), General OB/GYN 0.67 (0.50–0.90), and MIGS 0.56 (0.40–0.76) — with a ~11% decline in 2020 (RR 0.89, 0.85–0.92; p < 0.001) and no overall per-physician time trend (year RR 1.00, 0.99–1.00; p = 0.52) (Table 3). The one-value-per-physician secondary analysis agreed (Kruskal-Wallis H = 66.1, df = 3, p < 0.001; URPS exceeded urology and General OB/GYN, pairwise p < 0.001).

### Surgeon Volume and Concentration

Pooled multi-year concentration among the three well-populated groups was lowest for URPS (Gini 0.51, HHI 27; top 10% performed 34.3%, top 20% 53.4%), intermediate for urology (Gini 0.52, HHI 35; top 20% 57.5%), and highest for General OB/GYN (Gini 0.55, HHI 89; top 20% 60.8%) (Table 2). Gini and HHI ranked the groups identically, but for all three the HHI was very low in absolute terms (27–89 of 10,000): sling volume is distributed unevenly across many surgeons rather than dominated by a few, and no surgeon approaches a concentrating share. Median annual volume and its upper tail were highest for URPS (median 19, p75 27). Computed separately for each year, within-year concentration was modest and stable (pooled annual Gini 0.26–0.28; no temporal trend, slope ≈ 0.000/year, p = 0.82; annual top-20% ~38%), and no individual group's annual Gini trended (p > 0.15). Thus sling care did not become concentrated among a shrinking set of high-volume surgeons even as the surgeon pool contracted. MIGS is deliberately excluded from these concentration comparisons: with only 10 physicians (1–4 observable per year), its nominal values (Gini 0.60, HHI 2,919) are numerically extreme but not a clinically stable statement about specialty-wide concentration.

### Workforce Entry and Exit

Applying a two-year washout (Table 5), newly observable entrant surgeons numbered 48–184 per year and performed 7.4%–22.5% of that year's volume, at a low median entrant volume (~13 slings/year) — consistent with providers appearing just above the CMS suppression threshold. Entry collapsed in 2020 (48 entrants; 7.4% of volume) and rebounded in 2022 (168; 22.5%). Continuing surgeons (381–543 per year) performed the large majority of annual volume, and apparent exits ranged from 66 to 230 per year. Across the period URPS contributed the most entrants (440), followed by urology (373), General OB/GYN (189), and MIGS (8). Decomposing the specialty-share changes: the rising URPS share was driven by the largest inflow of newly observable URPS surgeons together with a stable continuing-URPS base (URPS surgeon count 385 → 338; per-physician volume flat), whereas urology's decline reflected net attrition despite substantial churn — many entrants offset by more exits — and General OB/GYN lost both surgeons and share. Because total volume fell, the gynecologic gain is a redistribution of a shrinking pool toward URPS, not new procedure growth. Given CMS suppression, all counts describe *newly observable* rather than definitively new sling surgeons.

### Geographic Distribution (Secondary)

Provider practice location spanned 52 states and territories. The URPS share of observable sling surgeons varied widely by state, from 100% (Hawaii) and 82%–85% (Minnesota, District of Columbia, Connecticut) to 15% (Nebraska). Four states or territories had no observable URPS surgeon performing at least 11 Medicare slings in any study year (North Dakota, Alaska, Puerto Rico, Wyoming); given CMS suppression, this indicates the absence of *observable* high-volume URPS surgeons, not necessarily the absence of any URPS physician. Population-based rates and formal geographic inequality measures were not computed and are proposed as a separate access-focused analysis.

## Discussion

This national analysis of Medicare claims from 2013 to 2023 shows that URPS physicians perform the majority of midurethral sling procedures (60.8%), with the highest adjusted per-physician volume and the most equitable within-group distribution. The combined gynecologic share increased significantly over the decade, and workforce decomposition attributes that rise to non-URPS attrition and URPS entry rather than to intensifying individual practice or concentrating care.

### Specialty Distribution and the Historical Reversal

Our finding that fellowship-trained urogynecologists perform roughly three-fifths of Medicare slings, with gynecologists collectively performing the majority, is consistent with contemporary practice-pattern data but marks a reversal from earlier Medicare-specific analyses. Using ACS-NSQIP (2006–2013), James et al. found gynecologists performed 74.2% of sling procedures versus 25.8% by urologists,^9^ and Cantrell et al. reported that urogynecologists performed 54% of stress-incontinence procedures at academic centers (2009–2014).^10^ In the Medicare population specifically, however, Rogo-Gupta et al. found that urologists performed the majority of sling operations in 2002–2007.^11^ Our data, spanning 2013–2023, show that this historical pattern has reversed, with URPS now accounting for the single largest share.

Identifying urogynecologists through both the ABOG (obstetrics-gynecology) and ABU (urology) certifying pathways is central to this result, because URPS is certifiable from either residency. Cross-referencing the ABU roster reassigned 150 urology-typed physicians (8.2% of all slings) to URPS, and the finding was robust — the pooled URPS Gini changed negligibly (0.51 → 0.52). A pathway-agnostic definition is important given that urology- and gynecology-based URPS fellows accrue different intraoperative case volumes during training^14^ and that FPMRS exposure during urology residency is variable;^15^ classifying urology-pathway urogynecologists as general urologists would understate the true subspecialty share.

### Procedural Concentration and the Volume–Outcome Relationship

Reporting the Gini coefficient and the Herfindahl–Hirschman Index together makes the concentration finding difficult to attribute to a single metric: the two answer related but distinct questions and agree here. Moderate inequality (Gini 0.51–0.55) coexists with very low absolute HHI (27–89 of 10,000), indicating that sling volume is spread unevenly across many surgeons rather than dominated by a few. Treating each physician as the operative production unit is a surgeon-level, not a market-competition, measure and follows workforce-concentration approaches used in other surgical specialties.

These patterns have clinical significance given the established volume–outcome relationship for midurethral slings. Berger et al. found that higher-volume surgeons had a substantially lower adjusted risk of reoperation for sling failure,^16^ and a systematic review by Cartier et al. found that low-volume surgeons had higher odds of both mesh revision and repeat incontinence procedures.^17^ Brennand and Quan identified a threshold effect, with revision odds declining above roughly 50 cases per year,^18^ and Holdø and Svenningsen found that greater surgeon experience and annual volume improved objective cure rates.^19^ The median observed volumes here (15–19 procedures/year) fall below these thresholds, but the PUF captures only Medicare fee-for-service claims; true per-surgeon volumes — including commercially insured, Medicare Advantage, and younger patients — are higher, and the reported concentration is a lower bound because sub-11-beneficiary providers are suppressed.

### Temporal Trends, Workforce Dynamics, and the Evolving SUI Landscape

The repeated-measures model and workforce decomposition together clarify the mechanism behind the rising gynecologic share. Individual physician volume did not change over time (year rate ratio 1.00), while the number of non-URPS surgeons fell sharply and URPS numbers held steady; entrant analysis showed URPS contributing the largest inflow of newly observable surgeons and urology exhibiting churn (many entrants offset by more exits) alongside net decline. The market-share shift is therefore a change in workforce composition superimposed on a shrinking total pool, not intensification of individual practice or concentration of care. This mechanism echoes prior work: Siegal et al. showed that the post-2011 decline in sling placement was driven primarily by non-FPMRS providers, while FPMRS providers maintained their volumes,^12^ and Lee et al. documented an approximately 50% national decline in incontinence surgery from 2004 to 2013.^13^ The significant 2020 decline (rate ratio 0.89) is consistent with pandemic-related deferral of elective surgery and was robust to excluding 2020. Finally, the SUI treatment landscape continues to diversify — urethral bulking agents are now positioned alongside slings as a first-line surgical option^3,20^ — and whether this differentially affects specialty-specific sling volumes warrants continued surveillance.

### Limitations

Several limitations warrant discussion. First, CMS suppresses provider-level data below 11 beneficiaries, so the lowest-volume providers are unobserved and reported concentration is a lower bound. Second, the PUF captures only fee-for-service Medicare Part B; younger, Medicare Advantage, Medicaid, commercially insured, and uninsured patients are not represented. Third, specialty classification depends on CMS provider type and the ABOG/ABU rosters; providers who completed URPS fellowship but are not board-certified would be misclassified. Fourth, the market-share trend is bounded rather than point-identified. Board certification lags the start of subspecialty practice — physicians complete fellowship and practice urogynecology before sitting for boards, and the 2013 inaugural examination certified an established practicing cohort — so the certification-gated scheme (upper bound) misattributes pre-certification practice years to General OB/GYN or urology, while fixed membership (lower bound) retroactively counts physicians as URPS before they subspecialized. The true trend lies between; a point estimate would require fellowship-completion dates, which are not available. Additionally, ~8% of URPS providers could not be matched to a certification year and urology-pathway URPS were held fixed (no urology-subspecialty date), both of which shrink the upper-bound estimate. Fifth, the exclusion of 2017 removes one year of the time series (the underlying file being truncated); re-running with a complete 2017 file would restore all 11 years. Sixth, Tot_Srvcs may include bilateral or modifier-inflated services.

### Strengths

This study uses a national, 100% sample of Medicare fee-for-service claims; identifies urogynecologists through both training pathways; reports concentration with two complementary surgeon-level measures at both the pooled and annual level; accounts for the non-independence of repeated physician-year observations with a clustered model; and is fully reproducible.

## Conclusions

In this national Medicare cohort, URPS physicians perform the majority of midurethral slings with the highest adjusted per-physician volume and the most equitable within-group distribution. The growing gynecologic market share is driven by attrition of non-URPS providers rather than by increasing surgeon-level concentration, with implications for training requirements, credentialing standards, and access to pelvic floor surgical care.

## References

1. Wu JM. Stress incontinence in women. N Engl J Med. 2021;384(25):2428-2436.

2. Ford AA, Rogerson L, Cody JD, Aluko P, Ogah JA. Mid-urethral sling operations for stress urinary incontinence in women. Cochrane Database Syst Rev. 2017;7(7):CD006375.

3. Kobashi KC, Vasavada S, Bloschichak A, et al. Updates to surgical treatment of female stress urinary incontinence (SUI): AUA/SUFU guideline (2023). J Urol. 2023;209(6):1091-1098.

4. Birkmeyer JD, Stukel TA, Siewers AE, Goodney PP, Wennberg DE, Lucas FL. Surgeon volume and operative mortality in the United States. N Engl J Med. 2003;349(22):2117-2127.

5. Reames BN, Ghaferi AA, Birkmeyer JD, Dimick JB. Hospital volume and operative mortality in the modern era. Ann Surg. 2014;260(2):244-251.

6. American Board of Medical Specialties. ABMS announces approval of new subspecialty certificate in female pelvic medicine and reconstructive surgery. 2011. Available at: https://www.abms.org.

7. Berger AA, Tan-Kim J, Menefee SA. The impact of the 2011 US Food and Drug Administration transvaginal mesh communication on utilization of synthetic mid-urethral sling procedures. Int Urogynecol J. 2021;32(8):2227-2231.

8. Stitzenberg KB, Sigurdson ER, Egleston BL, Starkey RB, Meropol NJ. Centralization of cancer surgery: implications for patient access to optimal care. J Clin Oncol. 2009;27(28):4671-4678.

9. James MB, Theofanides MC, Sui W, Onyeji I, Badalato GM, Chung DE. Sling procedures for the treatment of stress urinary incontinence: comparison of national practice patterns between urologists and gynecologists. J Urol. 2017;198(6):1386-1391.

10. Cantrell AB, Rothschild J, Durbin-Johnson B, Gonzalez R, Kurzrock EA. Surgical trends in the correction of female stress urinary incontinence in academic centers within the United States. Neurourol Urodyn. 2017;36(2):394-398.

11. Rogo-Gupta L, Litwin MS, Saigal CS, Anger JT; Urologic Diseases in America Project. Trends in the surgical management of stress urinary incontinence among female Medicare beneficiaries, 2002-2007. Urology. 2013;82(1):38-41.

12. Siegal AR, Huang Z, Gross MD, Mehraban-Far S, Weissbart SJ, Kim JM. Trends of mesh utilization for stress urinary incontinence before and after the 2011 Food and Drug Administration notification between FPMRS-certified and non-FPMRS-certified physicians: a statewide all-payer database analysis. Urology. 2021;150:151-157.

13. Lee UJ, Feinstein L, Ward JB, et al; Urologic Diseases in America Project. National trends in the surgical management of urinary incontinence among insured women, 2004 to 2013. J Urol. 2020;203(2):365-371.

14. Tabakin AL, Sawhney R, Daily AM, Winkler HA, Shalom DF, Tam J, Lee W. Case log trends of urogynecology and reconstructive pelvic surgery fellows: a comparison of urology- and gynecology-based fellowship programs. Neurourol Urodyn. 2024;43(8):1970-1976.

15. Wang CN, Su IW, Smith AL, Badalato GM, Chung DE. Current exposure to female pelvic medicine and reconstructive surgery faculty during urology residency. Neurourol Urodyn. 2023;42(7):1569-1573.

16. Berger AA, Tan-Kim J, Menefee SA. Surgeon volume and reoperation risk after midurethral sling surgery. Am J Obstet Gynecol. 2019;221(5):523.e1-523.e8.

17. Cartier S, Cerantola GM, Leung AA, Brennand E. The impact of surgeon operative volume on risk of reoperation within 5 years of mid-urethral sling: a systematic review. Int Urogynecol J. 2023;34(5):981-992.

18. Brennand EA, Quan H. Evaluation of the effect of surgeon's operative volume and specialty on likelihood of revision after mesh midurethral sling placement. Obstet Gynecol. 2019;133(6):1099-1108.

19. Holdø B, Svenningsen R. The impact from surgical experience on short- and long-term success rates after mid-urethral sling surgery. Int Urogynecol J. 2026 (epub ahead of print).

20. Gallo K, Weiner H, Mishra K. An update on surgical management for stress urinary incontinence. Curr Opin Obstet Gynecol. 2024;36(6):433-438.

---

## Tables

**Table 1.** Specialty distribution and market-share trends of CPT 57288 providers, Medicare PUF 2013–2023 (2017 excluded; combined URPS). Δ share = annual percentage-point change in market share (OLS on calendar year). Physician counts sum to more than the unique total (1,745) because 13 physicians changed specialty group across years.

| Specialty | Unique physicians | Physician-years | Procedures | % of all | Median vol (p25–p75) | 2013 share | 2023 share | Δ share/yr (95% CI) | p |
|-----------|------------------|-----------------|-----------|----------|----------------------|-----------|-----------|---------------------|---|
| URPS | 753 | 3,498 | 80,033 | 60.8% | 19 (14–27) | 53.4% | 63.8% | +0.90 (0.49 to 1.31) | <0.001 |
| Urology (non-URPS) | 665 | 1,810 | 34,351 | 26.1% | 16 (13–22) | 30.7% | 23.1% | −0.55 (−0.87 to −0.23) | 0.004 |
| General OB/GYN | 330 | 858 | 16,391 | 12.5% | 15 (12–22) | 15.7% | 12.3% | −0.42 (−0.68 to −0.16) | 0.006 |
| MIGS | 10 | 36 | 862 | 0.7% | 16 (12–24) | 0.2% | 0.8% | +0.07 (0.02 to 0.12)* | 0.008 |
| **Total** | **1,745** | **6,202** | **131,637** | **100%** | — | — | — | — | — |

\*MIGS (n = 10) reported descriptively; too few physicians for a stable specialty-wide inference.

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

**Table 4.** Market-share trends under classification schemes that bracket the true trend. Fixed-membership is a lower bound (treats not-yet-certified physicians as already URPS); time-varying certification-gated is an upper bound (board certification lags practice onset). All schemes are significant and positive.

| Analysis | 2013 → 2023 | Slope (pp/year) | p-value |
|----------|-------------|-----------------|---------|
| Lower bound — gynecologic share (fixed; ABOG-URPS + MIGS + Gen OB/GYN) | 60.8% → 70.1% | 0.84 | < 0.001 |
| Lower bound — combined-URPS share (fixed) | 53.4% → 63.8% | 0.90 | < 0.001 |
| Sensitivity — URPS share (modal) | — | 0.98 | < 0.001 |
| Sensitivity — URPS share (ever-URPS/MIGS) | — | 0.96 | 0.001 |
| **Upper bound — URPS share (time-varying, cert-gated)** | **46.3% → 74.2%** | **2.28** | **< 0.001** |
| Upper bound — gynecologic share (time-varying, cert-gated) | — | 1.33 | < 0.001 |

**Table 5.** Annual sling workforce dynamics (newly observable surgeons; two-year washout). Entrants were absent in both prior observable years; exiting surgeons were absent in both subsequent observable years. Entrant/continuing counts are undefined for the first two years and exiting counts for the last two.

| Year | Observable | Entrants | Continuing | Exiting | % volume by entrants | Median entrant volume |
|------|-----------|----------|-----------|---------|----------------------|-----------------------|
| 2013 | 812 | — | — | 214 | — | — |
| 2014 | 685 | — | — | 164 | — | — |
| 2015 | 655 | 127 | 528 | 136 | 14.2% | 13 |
| 2016 | 701 | 158 | 543 | 219 | 15.3% | 13 |
| 2018 | 672 | 184 | 488 | 154 | 20.6% | 14 |
| 2019 | 650 | 122 | 528 | 230 | 12.4% | 13 |
| 2020 | 445 | 48 | 397 | 66 | 7.4% | 13 |
| 2021 | 458 | 77 | 381 | 81 | 12.1% | 13 |
| 2022 | 562 | 168 | 394 | — | 22.5% | 14 |
| 2023 | 562 | 126 | 436 | — | 15.7% | 13 |

Entrants by specialty over the period: URPS 440, urology 373, General OB/GYN 189, MIGS 8.

---

## Figures

**Figure 1.** Market share of midurethral sling procedures (CPT 57288) by specialty group, Medicare PUF 2013–2023 (2017 excluded). The URPS/gynecologic share rose significantly under every classification scheme; fixed-membership classification (+0.84 pp/year, gynecologic share 60.8% → 70.1%) and time-varying certification-gated classification (+2.28 pp/year, URPS share 46.3% → 74.2%) bracket the true trend.

**Figure 2.** Distribution of annual midurethral sling volume by specialty group (violin + box plots, log scale). The minimum observable volume is 11 due to CMS cell suppression.

**Figure 3.** Lorenz curves of procedural concentration by specialty. Curves farther from the diagonal indicate greater concentration; URPS (Gini 0.51) is closest to equality, MIGS (0.60) farthest.

**Figure 4.** Annual procedural concentration by specialty (Gini, HHI, top-20% and bottom-50% shares) per calendar year; within-year concentration is low and stable. MIGS excluded from these panels (too few surgeons/year for a stable estimate).

**Figure 5.** Observable surgeons and total procedure volume per year by specialty; the surgeon-pool decline is concentrated in urology and General OB/GYN.
