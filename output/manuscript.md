# Specialty Distribution, Procedural Concentration, and Time Trends in Midurethral Sling Surgery Among Medicare Beneficiaries, 2013–2023

Tyler Muffly, MD

## Abstract

**Objective:** To characterize the specialty distribution, annual procedure volumes, and procedural concentration among physicians performing midurethral sling procedures (CPT 57288) in Medicare beneficiaries.

**Methods:** We analyzed the CMS Medicare Physician and Other Practitioners Public Use File (2013–2023). Providers billing CPT 57288 were classified as Urogynecology and Reconstructive Pelvic Surgery (URPS), Minimally Invasive Gynecologic Surgery (MIGS), General OB/GYN, or urology using CMS provider type cross-referenced with the ABOG subspecialty registry. Procedural concentration was quantified using Gini coefficients and the share performed by the top 20% of providers. Volume differences were assessed by Kruskal-Wallis and pairwise Wilcoxon tests (Bonferroni-corrected). Gynecologic market-share trends were assessed by linear regression. CMS suppresses counts of 1–10 services; providers below this threshold are absent from the data.

**Results:** A total of 1,775 unique providers billed CPT 57288 across the study period, accounting for 139,855 procedures. URPS physicians represented the largest group, accounting for 52.7% of all procedures at a median annual volume of 19 (IQR 14–29) procedures per year (609 providers). Urology accounted for 823 providers (34.2% of procedures; median 16, IQR 13–22). General OB/GYN accounted for 333 providers (12.4%; median 15, IQR 12–22). MIGS accounted for 10 providers (0.6%; median 16, IQR 12–23). Annual sling volume differed significantly across specialty groups (Kruskal-Wallis H = 291.8, df = 3, p < 0.001). Procedural concentration varied by specialty: URPS (Gini 0.51; top 20% performed 53%); Urology (Gini 0.54; top 20% performed 58.9%); General OB/GYN (Gini 0.56; top 20% performed 61.9%); MIGS (Gini 0.59; top 20% performed 67%). The combined gynecologic share increased significantly from 60.3% in 2013 to 69.9% in 2023 (slope = 0.84 percentage points per year; p < 0.001).

**Conclusions:** URPS physicians perform the majority of midurethral sling procedures in Medicare with the most equitable volume distribution. The growing gynecologic market share and specialty-specific concentration patterns have implications for credentialing standards and workforce planning for pelvic floor surgical care.

---

## Introduction

The midurethral sling is the most commonly performed surgical procedure for stress urinary incontinence (SUI) and is considered the gold standard treatment when conservative measures fail.^1,2^ Coded as CPT 57288, the procedure involves placement of a synthetic mesh sling beneath the mid-urethra to restore continence. Despite its central role in pelvic floor surgery, the specialty distribution and procedural concentration among physicians performing this operation in the Medicare population have not been well characterized.

Understanding who performs midurethral slings—and how procedure volume is distributed within each specialty—has direct implications for surgical quality, training requirements, and workforce planning. The volume-outcome relationship in surgery is well established: higher-volume surgeons and hospitals tend to achieve better patient outcomes across a range of procedures.^3,4^ However, the evidence base for volume thresholds in midurethral sling surgery specifically is limited, and the specialty landscape has evolved considerably over the past decade.

Several trends make this analysis timely. First, the subspecialty of Female Pelvic Medicine and Reconstructive Surgery—recently renamed Urogynecology and Reconstructive Pelvic Surgery (URPS)—has grown substantially since achieving American Board of Medical Specialties (ABMS) recognition in 2013.^5^ Second, the US Food and Drug Administration's reclassification of urogynecologic surgical mesh as a Class III device in 2016 and subsequent market withdrawal orders may have shifted the procedural landscape.^6^ Third, there is growing interest in procedural concentration—the degree to which a small number of providers account for a disproportionate share of procedures—as a metric relevant to quality improvement and resource allocation.^7^

The objective of this study was to characterize the specialty distribution, annual procedure volumes, and procedural concentration among physicians performing midurethral sling procedures in Medicare beneficiaries from 2013 to 2023. We further aimed to assess time trends in the gynecologic share of sling procedures and to quantify the degree to which procedural volume is concentrated among high-volume providers within each specialty group.

## Methods

### Study Design and Data Source

We conducted a repeated cross-sectional analysis of the Centers for Medicare & Medicaid Services (CMS) Medicare Physician and Other Practitioners Public Use File (PUF) from 2013 to 2023. This dataset contains 100% of fee-for-service Medicare Part B claims aggregated to the provider-service level, with one row per unique combination of National Provider Identifier (NPI), Healthcare Common Procedure Coding System (HCPCS) code, and place of service per calendar year. The dataset is publicly available and contains no protected health information; institutional review board approval was not required.

### Study Population

We identified all provider-year observations with HCPCS code 57288 (placement of a midurethral sling for stress urinary incontinence). Across the 11-year study period, this yielded 6,663 provider-year observations before specialty classification and exclusions.

### Specialty Classification

Providers were initially classified into broad specialty groups based on CMS-reported provider type (Rndrng_Prvdr_Type): obstetrics and gynecology (OB/GYN), urology, or other. Providers classified as "Other" by CMS whose NPIs did not appear in the American Board of Obstetrics and Gynecology (ABOG) subspecialty registry were reclassified as urologists, on the assumption that non-OB/GYN, non-urology providers billing this code are most likely urologists with atypical CMS provider type designations (n = 310 reclassified).

OB/GYN providers were further subdivided using the ABOG subspecialty registry, which contains NPI-linked subspecialty certification data for all ABOG diplomates. Providers with an ABOG subspecialty of "Female Pelvic Medicine and Reconstructive Surgery" were classified as URPS (Urogynecology and Reconstructive Pelvic Surgery, reflecting the 2024 ABMS-approved name change). Providers with an ABOG subspecialty designation of "MIG" (Minimally Invasive Gynecologic Surgery) were classified as MIGS. All remaining OB/GYN providers—including ABOG-certified generalists and providers not found in the ABOG registry—were classified as General OB/GYN.

Providers whose CMS provider type did not match OB/GYN, urology, or any identifiable surgical specialty (n = 80 records from General Surgery, osteopathic specialties, and undefined types) were excluded from analysis as too heterogeneous and small to interpret meaningfully.

### CMS Data Suppression

CMS suppresses provider-service level data when a provider serves fewer than 11 Medicare beneficiaries for a given HCPCS code in a calendar year. This means that all providers in our dataset performed at least 11 midurethral sling procedures per year—the true number of low-volume providers is unknowable from these data. This left-truncation is an inherent limitation of the PUF and must be considered when interpreting volume distributions and concentration metrics.

### Outcome Measures

The primary outcome was the annual midurethral sling count per provider (Tot_Srvcs from the PUF), summarized as median with interquartile range (IQR) by specialty group. Secondary outcomes included:

1. **Procedural concentration**, quantified using the Gini coefficient (ranging from 0 for perfect equality to 1 for maximum concentration) and the percentage of procedures performed by the top 20% of providers within each specialty group. Gini coefficients were computed on aggregate (multi-year) provider-level total volumes.

2. **Market share trends**, defined as the percentage of all midurethral sling procedures performed by each specialty group per calendar year.

### Statistical Analysis

Differences in annual procedure volume across specialty groups were assessed using the Kruskal-Wallis test, a non-parametric omnibus test appropriate for the right-skewed volume distributions observed. Pairwise comparisons between the two largest groups (URPS and urology) were performed using the Wilcoxon rank-sum test with Bonferroni correction.

Time trends in the combined gynecologic share (URPS + MIGS + General OB/GYN) were assessed by ordinary least-squares linear regression of annual market-share percentage on calendar year. The slope represents the average annual change in gynecologic market share in percentage points per year.

All analyses were performed in R version 4.4.0. Package versions were locked using renv (version 1.0.7) for reproducibility. The complete analysis pipeline, including all code and configuration, is available at https://github.com/mufflyt/sling-volume-patterns.

## Results

### Overall Volume and Specialty Distribution

A total of 1,775 unique providers billed CPT 57288 at least once during the 11-year study period, accounting for 139,855 procedures (Table 1). Annual procedure counts ranged from 8,218 (2017) to 16,399 (2013), with a notable decline in 2017 that partially recovered by 2018.

URPS physicians constituted the largest specialty group, with 609 providers performing 73,751 procedures (52.7% of all slings). Urologists were the second largest group, with 823 providers performing 47,825 procedures (34.2%). General OB/GYN accounted for 333 providers and 17,402 procedures (12.4%). MIGS providers were rare, with only 10 providers performing 877 procedures (0.6%).

### Procedure Volume by Specialty

URPS providers had the highest median annual volume at 19 procedures per year (IQR 14–29; mean 23.7), significantly higher than urologists at 16 (IQR 13–22; mean 19.1), General OB/GYN at 15 (IQR 12–22; mean 19.2), and MIGS at 16 (IQR 12–23; mean 23.7). Annual sling volume differed significantly across all four specialty groups (Kruskal-Wallis H = 291.8, df = 3, p < 0.001). In the pairwise comparison of the two largest groups, URPS providers performed significantly more slings per year than urologists (Wilcoxon p < 0.001, Bonferroni-corrected).

The volume distributions were right-skewed in all groups (Figure 2), with outlier high-volume providers performing up to 98 (URPS), 92 (urology), 77 (MIGS), and 73 (General OB/GYN) procedures per year. The minimum observable volume was 11 in all groups, reflecting CMS cell suppression.

### Procedural Concentration

Procedural concentration, measured by the Gini coefficient on aggregate provider-level volumes, varied across specialty groups (Table 2, Figure 3). URPS had the lowest Gini coefficient (0.51), indicating the most equitable distribution of sling volume among its providers. The top 20% of URPS providers performed 53.0% of all URPS slings, and the top 10% performed 33.6%.

Urology showed moderate concentration (Gini 0.54), with the top 20% performing 58.9% of urology slings. General OB/GYN was more concentrated (Gini 0.56; top 20% performed 61.9%), suggesting that a relatively small number of generalist OB/GYNs account for the majority of generalist sling volume. MIGS showed the highest concentration (Gini 0.59; top 20% performed 67.0%), although interpretation is limited by the small group size (n = 10 providers).

### Time Trends in Market Share

The combined gynecologic share of midurethral sling procedures (URPS + MIGS + General OB/GYN) increased significantly from 60.3% in 2013 to 69.9% in 2023 (slope = 0.84 percentage points per year; p < 0.001; Figure 1). This increase was driven primarily by URPS, whose share rose from 44.3% in 2013 to 56.9% in 2023. Conversely, urology's share declined from 39.7% to 30.1%, and General OB/GYN's share decreased from 15.7% to 12.3%.

The number of urologists billing CPT 57288 declined substantially from 363 in 2013 to 189 in 2023, a 48% decrease. The number of URPS providers showed a more modest decline from 304 to 293 (3.6%), while General OB/GYN providers decreased from 142 to 76 (46%). These changes suggest that urology and generalist OB/GYN are losing providers from the sling workforce more rapidly than URPS.

## Discussion

This national analysis of Medicare claims from 2013 to 2023 reveals that URPS physicians perform the majority of midurethral sling procedures, accounting for 52.7% of all slings with the highest per-provider volume and the most equitable volume distribution. The combined gynecologic share of sling procedures has increased significantly over the past decade, rising from 60.3% to 69.9%, driven primarily by growth in the URPS share.

### Subspecialty Dominance and the ABOG Crosswalk

A key methodological contribution of this study is the use of the ABOG subspecialty registry to disaggregate the OB/GYN provider type into URPS, MIGS, and General OB/GYN. Without this crosswalk, the CMS PUF groups all OB/GYN subspecialties together, obscuring the fact that 78% of OB/GYN providers billing for midurethral slings are URPS-certified subspecialists. This finding reframes the narrative: midurethral sling surgery in Medicare is predominantly performed by fellowship-trained urogynecologists, not generalist OB/GYNs.

The 10 MIGS providers identified performing slings is a novel finding. While MIGS fellowship training emphasizes minimally invasive approaches to gynecologic surgery, the midurethral sling is not traditionally considered a core MIGS procedure. The small number of MIGS providers in this dataset may represent surgeons with dual expertise or those whose practice encompasses pelvic floor surgery.

### Procedural Concentration

The Gini coefficients observed (0.51–0.59) indicate moderate procedural concentration across all specialty groups. For context, a Gini of 0.51 means that if sling volume were distributed perfectly equally among URPS providers, each would perform the same number—the actual distribution deviates 51% from this ideal. The finding that URPS has the lowest concentration (most equitable distribution) is consistent with the subspecialty's focused training in pelvic floor procedures, which may promote a more uniform practice pattern.

General OB/GYN's higher Gini coefficient (0.56) suggests greater heterogeneity: some generalists maintain robust sling practices while others perform the procedure infrequently. This has implications for credentialing and privileging decisions, as hospitals must balance access to surgical care with the evidence linking higher procedure volume to better outcomes.^3,4^

### Temporal Trends and Workforce Implications

The significant increase in gynecologic market share over the study period reflects two concurrent phenomena: the maturation and growth of URPS as a subspecialty, and the declining participation of urologists and generalist OB/GYNs in sling surgery. The 48% decline in the number of urologists billing CPT 57288 (363 in 2013 to 189 in 2023) is particularly striking. This may reflect subspecialization within urology, with fewer general urologists performing sling procedures as the procedure migrates toward URPS-trained pelvic floor specialists.

The 2017 dip in total procedure volume (8,218 procedures, down from 14,935 in 2016) coincides with the FDA's reclassification of surgical mesh and heightened public concern about mesh complications.^6^ While volume partially recovered by 2018 (15,002 procedures), the provider count never fully recovered to pre-2017 levels, suggesting that some providers permanently exited the sling workforce during this period.

### CMS Data Suppression as a Limitation

A fundamental limitation of this study is that CMS suppresses provider-level data when fewer than 11 beneficiaries are served for a given HCPCS code. This means our dataset necessarily excludes the lowest-volume providers—those performing 1 to 10 slings per year. The true number of providers performing midurethral slings is therefore larger than the 1,775 identified here, and the true distribution of volume is more right-skewed (and more concentrated) than what we observe. The Gini coefficients reported here should be interpreted as lower bounds on true procedural concentration.

This suppression also precludes the traditional "low-volume surgeon" analysis that defines a binary threshold (e.g., fewer than 10 procedures per year). Since no provider in the PUF can have fewer than 11 procedures, any threshold at or below 10 yields zero low-volume providers by construction. We adopted the Gini coefficient and top-N% share metrics specifically to characterize concentration within the observable portion of the volume distribution without relying on an arbitrary binary threshold.

### Additional Limitations

Several additional limitations warrant discussion. First, the Medicare PUF captures only fee-for-service Medicare Part B claims. Procedures performed on younger patients, those with Medicare Advantage, Medicaid, commercial insurance, or the uninsured are not represented. The specialty distribution and volume patterns in these populations may differ. Second, our specialty classification depends on the accuracy of CMS provider type coding and the ABOG subspecialty registry. Providers who completed URPS fellowship training but are not ABOG-certified would be misclassified as General OB/GYN. Third, the ABOG crosswalk is a snapshot; providers who obtained subspecialty certification during the study period may be classified as URPS for all years despite billing as generalists in earlier years. Fourth, Tot_Srvcs in the PUF includes all services billed, which may include bilateral procedures or procedures with modifiers that inflate the apparent volume.

### Strengths

This study has several strengths. It uses 11 years of complete Medicare claims data, providing a comprehensive view of temporal trends. The ABOG crosswalk enables granular specialty classification not possible from CMS data alone. The Gini coefficient provides a continuous, assumption-free measure of concentration that avoids the pitfalls of arbitrary volume thresholds. The entire analysis pipeline is publicly available and reproducible.

## Conclusions

In this national analysis of Medicare midurethral sling procedures from 2013 to 2023, URPS physicians perform the majority of slings with the highest per-provider volume and the most equitable volume distribution. The growing gynecologic share—driven by URPS—and the declining participation of urologists and generalist OB/GYNs in sling surgery suggest an ongoing shift in the procedural landscape. These findings have implications for surgical training requirements, credentialing standards, and equitable access to pelvic floor surgical care.

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

**Table 1.** Specialty distribution of CPT 57288 providers, Medicare PUF 2013–2023.

| Specialty | N providers | Total slings | % of all slings | Median annual volume (IQR) | Mean annual volume | Gini coefficient |
|-----------|-------------|-------------|-----------------|---------------------------|-------------------|-----------------|
| URPS | 609 | 73,751 | 52.7% | 19 (14–29) | 23.7 | 0.28 |
| Urology | 823 | 47,825 | 34.2% | 16 (13–22) | 19.1 | 0.24 |
| General OB/GYN | 333 | 17,402 | 12.4% | 15 (12–22) | 19.2 | 0.26 |
| MIGS | 10 | 877 | 0.6% | 16 (12–23) | 23.7 | 0.36 |
| **Total** | **1,775** | **139,855** | **100%** | — | — | — |

*Note: Gini coefficient in Table 1 is computed on annual provider-year volumes. The concentration Gini in Table 2 is computed on aggregate (multi-year) provider totals, yielding higher values.*

**Table 2.** Procedural concentration metrics by specialty group (aggregate provider-level volumes).

| Specialty | N providers | Gini coefficient | % by top 10% | % by top 20% | % by top 30% |
|-----------|-------------|-----------------|--------------|--------------|--------------|
| URPS | 609 | 0.51 | 33.6% | 53.0% | 67.3% |
| Urology | 823 | 0.54 | 39.4% | 58.9% | 71.2% |
| General OB/GYN | 333 | 0.56 | 44.1% | 61.9% | 73.0% |
| MIGS | 10 | 0.59 | 47.5% | 67.0% | 74.7% |

**Table 3.** Statistical tests.

| Test | Comparison | Test statistic | p-value |
|------|-----------|---------------|---------|
| Kruskal-Wallis | All specialty groups | H = 291.8, df = 3 | < 0.001 |
| Wilcoxon (Bonferroni) | URPS vs Urology | — | < 0.001 |
| Linear regression | Gynecologic market share ~ year | slope = 0.84 | < 0.001 |

---

## Figures

**Figure 1.** Market share of midurethral sling procedures (CPT 57288) by specialty group, Medicare PUF 2013–2023. The combined gynecologic share (shaded area) increased significantly from 60.3% in 2013 to 69.9% in 2023 (slope = 0.84 percentage points per year; p < 0.001). URPS physicians consistently accounted for the largest share, rising from approximately 44% to 57% over the study period. Urology's share declined correspondingly from approximately 40% to 30%. General OB/GYN share decreased modestly from approximately 16% to 12%. MIGS providers contributed less than 1% throughout.

**Figure 2.** Distribution of annual midurethral sling procedure volume by specialty group, Medicare PUF 2013–2023. Violin plots with embedded box plots and jittered individual observations show the volume distribution on a log scale. URPS providers had the highest median annual volume (19 procedures; IQR 14–29), followed by MIGS (16; IQR 12–23), Urology (16; IQR 13–22), and General OB/GYN (15; IQR 12–22). All groups showed right-skewed distributions with outlier high-volume providers exceeding 70 procedures per year. The minimum observable volume is 11 due to CMS cell suppression.

**Figure 3.** Lorenz curves depicting procedural concentration of midurethral sling procedures by specialty group, Medicare PUF 2013–2023. The dashed diagonal represents perfect equality, where each provider performs an equal share of procedures. Curves farther from the diagonal indicate greater concentration. URPS providers (Gini = 0.51) show the most equitable distribution of sling volume, with the curve closest to the diagonal. MIGS (Gini = 0.59) shows the highest concentration. Urology (Gini = 0.54) and General OB/GYN (Gini = 0.56) fall between these extremes.
