**Author:** Tyler Muffly, MD<sup>1</sup>

<sup>1</sup> *\[Affiliation to be completed: division, department,
institution, city, state\]*

**Corresponding author:** Tyler Muffly, MD. *\[mailing address,
telephone, and email to be completed\]*

**Funding:** *\[to be completed; state “None” if not applicable\]*

**Conflicts of interest:** *\[to be completed; state “The author reports
no conflicts of interest” if applicable\]*

**Acknowledgments:** *\[to be completed\]*

**Data and code availability:** The complete, reproducible analytic
pipeline and this manuscript source are available at
<https://github.com/mufflyt/sling-volume-patterns>. The CMS Medicare
Physician and Other Practitioners Public Use File and the CMS Program
Statistics Original Medicare Enrollment tables are publicly available
from data.cms.gov.

**Word count (abstract):** approximately 250. **Manuscript type:**
Original research.

------------------------------------------------------------------------

## Abstract

**Objectives:** To describe the specialty distribution, surgeon volume,
and concentration of clinicians performing sling surgery for stress
urinary incontinence (CPT 57288) in fee-for-service Medicare, 2013
through 2023.

**Methods:** Using the CMS Medicare Physician and Other Practitioners
Public Use File (all 11 years), we classified clinicians billing CPT
57288 as Urogynecology and Reconstructive Pelvic Surgery (URPS, both
certification pathways), Minimally Invasive Gynecologic Surgery, other
non-URPS OB/GYN, or non-URPS urology; facilities and unclassifiable
billers formed a separate group. Utilization was modeled with a
denominator offset (female Part B fee-for-service enrollment), annual
volume with a Poisson generalized estimating equation clustered by NPI,
and the URPS share with a quasibinomial model; concentration used the
Gini coefficient with bootstrap confidence intervals.

**Results:** 1,666 clinicians performed 141,009 observable services.
OB/GYN-pathway URPS was the largest group (55%), with urology-pathway
URPS a further 8.7% (together 63.7%), followed by non-URPS urology
(14.5%) and other non-URPS OB/GYN (13%). Raw services fell -27.7%, but
in a denominator-offset model the observable utilization rate declined
-1.9% per year (about -17.3% over the decade; p = 0.119), a meaningful
but not statistically robust decline. Adjusted volume was higher for
OB/GYN-pathway URPS than for the other groups. Within-year concentration
was low and stable (annual Gini 0.22–0.28). In a quasibinomial model the
OB/GYN-pathway URPS share rose 1.44 percentage points/year (48.3% to
62.6%; p &lt; 0.001); the urology pathway was roughly stable.

**Conclusions:** In observable fee-for-service Medicare, all-pathway
URPS physicians performed most sling surgery for stress urinary
incontinence, and their share rose as non-URPS participation declined,
not through rising concentration. These findings describe observable
Medicare service patterns, not the national surgical workforce; outcome
and access studies are needed before credentialing implications.

**Keywords:** stress urinary incontinence; sling surgery; urogynecology;
Medicare; surgical workforce; procedural concentration.

------------------------------------------------------------------------

## Simply Stated

Sling surgery is a common operation for stress urinary incontinence, a
condition that causes urine leakage with coughing, laughing, or
exercise. Several kinds of doctors perform this surgery, including
urogynecologists (subspecialists in pelvic floor surgery), general
obstetrician-gynecologists, and urologists. Using national Medicare
billing records from 2013 to 2023, we looked at who performs these
operations and how the work is spread among surgeons. Urogynecologists
performed most of the operations, and their share grew over the decade.
The total number of billed operations fell, but much of that drop
reflects that fewer older adults are now in traditional Medicare; after
accounting for that shrinking population, a smaller real decline may
remain, though the data cannot pin it down precisely. No small group of
very high-volume surgeons dominated the work. These findings describe
the traditional Medicare workforce and cannot, by themselves, tell us
who should be allowed to perform the surgery.

## Why This Matters

The mix of specialties performing stress-incontinence surgery bears on
training, credentialing, and patient access, yet national Medicare data
on it are limited. This study adds two things. First, it identifies
urogynecologists through both the obstetrics-gynecology and urology
certification pathways, which avoids undercounting the subspecialty.
Second, it shows that raw fee-for-service counts can be misleading:
after accounting for the shrinking traditional-Medicare population, the
apparent decline in sling surgery largely disappears, and within-year
concentration among surgeons stayed low and stable. For clinicians and
policymakers, the practical message is that observed shifts reflect
changing workforce composition, not consolidation of care into a few
hands, and that claims databases must be paired with enrollment
denominators and outcome data before they can support credentialing or
access decisions.

------------------------------------------------------------------------

## Introduction

Sling surgery is a common operation for stress urinary incontinence
(SUI) and remains a standard surgical treatment when conservative care
fails.<sup>1,2</sup> These operations are reported under CPT 57288,
whose descriptor is “sling operation for stress incontinence (eg, fascia
or synthetic).” The code therefore captures autologous fascial and
synthetic sling operations together and does not identify the sling
material or distinguish retropubic, transobturator, single-incision, or
pubovaginal technique. Despite the procedure’s widespread use, little is
known about which specialties perform these operations in the Medicare
population or how volume is distributed among surgeons.

These questions matter for surgical quality, training, and workforce
planning. Across surgery, higher surgeon and hospital volume is
generally associated with better outcomes.<sup>4,5</sup> Evidence for
procedure-specific volume thresholds in sling surgery is more limited.
The specialty mix has also changed during the past decade.

Three developments make this analysis timely. First, Female Pelvic
Medicine and Reconstructive Surgery, now named Urogynecology and
Reconstructive Pelvic Surgery (URPS), has grown since receiving American
Board of Medical Specialties recognition in 2013.<sup>6</sup>
Certification is available through both obstetrics and gynecology (ABOG)
and urology (ABU) pathways. Second, US Food and Drug Administration
actions on urogynecologic mesh changed public perception of mesh and may
have affected sling use.<sup>7</sup> The 2019 FDA order concerned
transvaginal mesh for pelvic organ prolapse and did not remove synthetic
midurethral slings for stress incontinence from the market; the two
devices are frequently conflated in public discussion. Third, procedural
concentration, the extent to which a relatively small group of
clinicians performs a large share of procedures, has become relevant to
quality improvement and resource allocation.<sup>8</sup>

We therefore characterized specialty distribution, annual surgeon
volume, and surgeon-level concentration among physicians performing
sling surgery for stress urinary incontinence in fee-for-service
Medicare from 2013 through 2023. We also evaluated changes in each
specialty’s share of reported services over time.

## Materials and Methods

### Study Design and Data Source

We conducted a repeated cross-sectional analysis of the Centers for
Medicare & Medicaid Services (CMS) Medicare Physician and Other
Practitioners Public Use File (PUF) from 2013 through 2023. The PUF
contains all fee-for-service Medicare Part B claims aggregated to the
provider-service level. Each row represents a unique combination of
National Provider Identifier (NPI), Healthcare Common Procedure Coding
System code, place of service, and calendar year. Because the dataset is
publicly available and contains no protected health information,
institutional review board approval was not required.

All 11 annual PUF releases (2013 through 2023) were verified against the
CMS file specifications for completeness before analysis.

### Specialty Classification

Providers were assigned to four mutually exclusive groups: URPS, MIGS,
General OB/GYN, or non-URPS urology. We first used the annual CMS
provider type (Rndrng\_Prvdr\_Type), which may vary by year, to identify
OB/GYN, urology, or another specialty. Among OB/GYN physicians, the ABOG
subspecialty registry (a snapshot of ABOG-certified diplomates linked to
NPIs primarily by exact NPI match and, when needed, by full name and
practice state) identified “Female Pelvic Medicine and Reconstructive
Surgery” as URPS and “MIG” as MIGS; all other OB/GYN physicians were
classified as General OB/GYN. This yielded 1666-cohort assignments of
URPS, MIGS, and General OB/GYN through the OB/GYN pathway.

Billers of CPT 57288 who had neither an OB/GYN nor urology CMS provider
type and were not in the ABOG registry (323 NPIs) were predominantly
facilities (ambulatory surgical centers) and non-physician clinicians
(physician assistants, nurse practitioners), not urologists; none
matched the ABU roster. We therefore did not assign them to urology.
Organizational NPIs (NPPES entity type 2, flagged in the Public Use File
by a rendering-provider entity code of “O”: ambulatory surgical centers,
hospitals, laboratories, and groups; 123 NPIs) were excluded because
they identify a billing organization rather than an individual clinician
and cannot be given a physician specialty. The remaining 200 individual
non-physician or unclassifiable clinicians were placed in a distinct
“Other/uncertain” group (8.2% of observable services). The full
classification flow, with counts at each step, is shown in Figure 3. We
report the specialty distribution under three handlings of these
billers, as a sensitivity analysis (Supplementary Table S11): the
primary “Other/uncertain” grouping, exclusion, and the legacy assignment
to urology; the latter inflates the apparent non-URPS urology share
roughly two-fold and is not used. A further small number of
provider-year records from ABOG-registered NPIs with a miscellaneous CMS
type remained “Other” and were excluded.

We then cross-referenced the American Board of Urology roster (355
urology-pathway urogynecologist NPIs) to identify urology-pathway
urogynecologists; 151 cohort physicians matched. These physicians were
combined with ABOG-certified urogynecologists into a single all-pathway
URPS group; all remaining urologists were classified as non-URPS
urology. Without this step, fellowship-trained urology-pathway
urogynecologists would appear only as “Urology” in the PUF. Because an
all-pathway URPS group includes urology-trained subspecialists who are
not gynecologists, we report the all-pathway URPS share separately from
the OB/GYN-based share (URPS plus MIGS plus General OB/GYN, restricted
to the OB/GYN training pathway), rather than a single “gynecologic”
share.

Specialty assignment could affect the estimated market-share trend
because 45% of URPS physicians in the cohort were certified after 2013.
We therefore examined two plausible classification scenarios that make
opposite assumptions about pre-certification practice years.
Fixed-membership classification assigns each physician’s eventual
subspecialty to every study year; because it counts physicians as URPS
before certification, it tends to produce a shallower estimated slope.

Time-varying, certification-gated classification counts a physician as
URPS or MIGS only beginning in the ABOG subspecialty certification year
(sub1startdate, 2013–2024, distinct from the initial OB/GYN board date).
Earlier years are classified by that year’s CMS provider type. Because
certification generally follows the start of subspecialty practice (the
2013 examination certified physicians already practicing urogynecology,
and later diplomates also practiced before certification), this scenario
removes some genuine pre-certification practice from the early URPS
count and tends to produce a steeper estimated slope. We present these
as plausible scenarios rather than formal statistical bounds, because
neither assumption is guaranteed to bracket the true trend.

Modal and ever-URPS/MIGS classifications were additional sensitivity
analyses. Urology-pathway URPS classification remained fixed because no
urology subspecialty certification date was available. For the
whole-period distribution, concentration, and volume analyses (Tables
1–3), each physician was assigned to the eventual combined subspecialty.

### CMS Data Suppression

CMS suppresses provider-service data when a provider treats fewer than
11 Medicare beneficiaries for a given code in a calendar year. Every
observable provider in this study therefore treated at least 11 Medicare
beneficiaries for CPT 57288 that year. Providers below the threshold are
not observed, so the true number of low-volume surgeons is unknown.
Suppression removes the lowest-volume physician-years and can bias the
Gini coefficient and HHI in different directions, so the full-market
concentration cannot be identified from the Public Use File. We
therefore report bootstrap confidence intervals for the Gini coefficient
and a sensitivity analysis that adds hypothetical suppressed low-volume
providers before recomputing concentration.

### Outcome Measures and Statistical Analysis

The primary surgeon-level outcome was the annual number of CPT 57288
services per provider (Tot\_Srvcs, reported services). To describe
population utilization over time, we also computed the annual rate of
CPT 57288 services per 100,000 female Part B fee-for-service Medicare
beneficiaries, using the CMS Program Statistics Original Medicare
Enrollment counts (table MDCR ENROLL AB 11, Sex = Female, Part B) as the
denominator; absolute service counts are reported as a secondary
measure. Because the Public Use File records no beneficiary age for the
numerator, the rate is crude and is not age-standardized. We measured
surgeon-level concentration with complementary metrics. The Gini
coefficient summarizes inequality across the full surgeon-volume
distribution, and we bootstrapped its 95% confidence interval by
resampling providers. The Herfindahl–Hirschman Index (HHI) sums squared
surgeon shares on a 0–10,000 scale and is more sensitive to the
largest-volume surgeons. Because the minimum attainable HHI depends on
the number of providers, we do not compare raw HHI directly across
groups of very different size (URPS 616, General OB/GYN 336, MIGS 10
physicians); we also report the size-adjusted normalized HHI and the
effective number of providers (1 divided by the sum of squared shares).
Within-year concentration, computed separately for each calendar year,
was the primary concentration measure; pooled multi-year values are
secondary because they mix annual volume with how many years each
physician remained observable.

The physician was the operative production unit in these calculations.
Thus, HHI describes surgeon-level procedural concentration rather than
hospital or health-system market competition and should not be
interpreted using FTC/DOJ antitrust thresholds.

Because each physician contributed as many as eleven annual
observations, physician-year records were correlated. We modeled the
annual count of reported services, conditional on the physician-year
being observable (above the CMS suppression threshold), with a Poisson
generalized estimating equation clustered by NPI, using an exchangeable
working correlation and robust standard errors. Fixed effects were
specialty (URPS reference), calendar year centered at 2018, a
specialty-by-year interaction, and a 2020 COVID indicator. Centering at
mid-study makes the specialty main effects the adjusted rate ratios at
2018; because the interaction makes the year term specialty-specific, we
report each specialty’s annual slope as a marginal linear contrast (the
year term plus its interaction) rather than a single overall time
effect. We report adjusted rate ratios with 95% CIs. A negative-binomial
mixed model with a random intercept for NPI was fit as a sensitivity
analysis, and its estimates are reported alongside the GEE. Additional
sensitivity analyses excluded calendar year 2020 and restricted the
cohort to physicians observable in at least two years.

As a secondary analysis with one independent observation per physician,
we compared each physician’s median annual volume across specialties
using the Kruskal-Wallis test and Bonferroni-adjusted pairwise Wilcoxon
tests.

To estimate the URPS market-share trend, we modeled URPS services as a
proportion of all annual services with a quasibinomial generalized
linear model on calendar year (centered at 2018), which respects the
compositional structure that separate ordinary least-squares regressions
on annual percentages ignore. We express the trend as an odds ratio per
year and as the marginal percentage-point change per year. Separate
ordinary least-squares regressions of each specialty’s annual percentage
share (URPS, urology, General OB/GYN) are reported as a descriptive
sensitivity. MIGS was described without formal emphasis because only 10
physicians were identified.

To describe observable participation transitions, we used a two-year
washout. A surgeon was counted as newly observable in a given year when
present but absent in both prior observable years; as continuing when
present and not newly observable; and as no longer observable when
absent in both subsequent observable years. We tabulated the share of
annual volume performed by newly observable surgeons, their median
volume, and their distribution by specialty. Because CMS suppression
removes providers below 11 beneficiaries, these transitions describe
when a surgeon crosses the reporting threshold, not genuine entry into
or exit from practice; a surgeon may become unobservable and later
reappear. Counts of newly observable surgeons by specialty are episode
counts (a physician observed as newly observable in more than one year,
after an intervening gap, contributes more than once), not counts of
unique physicians.

In a secondary geographic analysis, we tabulated observable surgeons and
URPS share by practice state and identified states with no observable
URPS surgeon performing at least 11 Medicare slings in any study year.
We did not calculate state-level population-based rates because
state-by-sex fee-for-service enrollment denominators were outside the
scope of this analysis; the national utilization rate above uses the
national female Part B fee-for-service denominator.

Analyses were performed in R 4.4, with package versions locked through
renv. The complete analytic pipeline is available at
<https://github.com/mufflyt/sling-volume-patterns>.

## Results

### Cohort and Annual Volume

Across the full 11-year window, 1,666 physicians billed CPT 57288,
accounting for 141,009 observed services in 6,569 physician-year
observations. Participation was intermittent: 505 physicians (30%)
appeared in one year, 707 (42%) in 2–5 years, 349 (21%) in 6–10 years,
and 105 (6%) in all 11 years. Thus, only a small proportion maintained
an observable Medicare sling practice throughout the study window.

The observed count of reported services fell from 15,872 in 2013 to
11,470 in 2023 (-27.7%). Over the same period the female Part B
fee-for-service population contracted from 18.35 million to 15.65
million beneficiaries (-14.7%). In a Poisson model of the annual service
count with log fee-for-service enrollment as an offset and a 2020
indicator, the observable utilization rate declined -1.9% per year (rate
ratio 0.981, 95% CI 0.961-1.002; about -17.3% over the decade), but with
only 11 annual observations and the pandemic interruption this trend was
not statistically robust (dispersion-adjusted p = 0.119). The rate
reached a low of 49.8 per 100,000 in 2020, consistent with
pandemic-related deferral of elective surgery, then partially recovered.
The number of observable surgeons also fell, from 779 to 522. A
clinically meaningful decline in observable utilization thus remains
possible, but the raw service-count drop overstates it because much of
that drop reflects the shrinking fee-for-service denominator; because
CMS suppresses low-volume physician-years, this is an
observable-services rate, not the total national fee-for-service rate.

### Specialty Distribution and Trends

We separated URPS into its two certification pathways (Table 1).
OB/GYN-pathway URPS (ABOG-certified) was the largest single group: 616
physicians, 77,501 services (55%), median annual volume 19 (p25–p75,
14–29). Urology-pathway URPS (ABU roster) added 151 physicians and
12,272 services (8.7%; median 16), so the two URPS pathways together
performed 63.7% of observable services. Non-URPS urology included 366
physicians and 20,475 services (14.5%; median 15), other non-URPS OB/GYN
336 physicians and 18,316 services (13%; median 15), the Other/uncertain
group 200 clinicians (8.2%), and MIGS 10 physicians (0.7%; median 16).

Because 13 clinicians changed specialty groups across years,
specialty-specific counts exceed the unique cohort total. The
urology-pathway URPS group (151 physicians, 12,272 services) would
otherwise be classified as general urology, understating the
subspecialty and overstating non-URPS urology.

Annual market shares moved in different directions (Table 1). URPS
increased from 45.8% in 2013 to 60.6% in 2023 (+1.42 percentage
points/year; 95% CI 1.03 to 1.80; p &lt; 0.001). Urology decreased from
22.4% to 8.3% (-1.28 percentage points/year; 95% CI -1.57 to -0.99; p
&lt; 0.001), and General OB/GYN decreased from 16.3% to 13.1% (-0.40
percentage points/year; 95% CI -0.66 to -0.13; p = 0.008). MIGS
increased descriptively from 0.2% to 0.9% (+0.08 percentage
points/year), but this estimate is based on only 10 physicians. In the
quasibinomial model of URPS services out of all annual services, which
respects the compositional structure, the URPS share rose from a fitted
48.3% in 2013 to 62.6% in 2023 (odds ratio 1.060 (95% CI 1.046-1.074)
per year; 1.44 percentage points per year; p &lt; 0.001), consistent
with the descriptive ordinary least-squares estimate. Because total
service counts declined, these changes represent redistribution among
specialties rather than growth in services.

The URPS increase was significant under every classification scenario,
which differed in the estimated slope (Table 4). Fixed membership gave
the shallower estimate because it counts physicians as URPS before
certification: the all-pathway URPS share rose from 55.1% to 68% (+1.12
percentage points/year), and the OB/GYN-based share from 16.5% to 13.9%
(+-0.32 percentage points/year). Certification-gated classification gave
the steeper estimate, from 43.6% to 66.9% (+1.76 percentage
points/year), because it removes not-yet-certified physicians from the
early URPS count; the two estimates converged near 66.9% by 2023.

In the Poisson GEE clustered by NPI (reference = OB/GYN-pathway URPS;
calendar year centered at 2018), adjusted annual volume at mid-study was
lower than OB/GYN-pathway URPS for every other group, including
urology-pathway URPS (RR 0.76 (0.68–0.84)), non-URPS urology (RR 0.71
(0.59–0.85)), other non-URPS OB/GYN (RR 0.63 (0.44–0.90)), and MIGS (RR
0.81 (0.51–1.29)) (Table 3). Annual volume was approximately 11% lower
in 2020 (RR 0.88 (0.85–0.91); p &lt; 0.001). The specialty-by-year
interaction showed that per-physician volume was essentially flat over
time for the well-populated groups (OB/GYN-pathway URPS RR 0.999
(0.990-1.007), p = 0.776; urology-pathway URPS RR 0.988 (0.974-1.002), p
= 0.089; non-URPS urology RR 0.986 (0.968-1.004), p = 0.137; other
OB/GYN RR 0.996 (0.973-1.020), p = 0.760), increasing only for the
10-physician MIGS group (RR 1.085 (1.031-1.142); p = 0.002) (Table 3). A
negative-binomial mixed model with a random intercept per NPI reproduced
the direction but with attenuated magnitude (urology RR 0.78
(0.74–0.82), General OB/GYN RR 0.81 (0.77–0.85), 2020 RR 0.90
(0.87–0.93)); the attenuation is expected because the GEE estimates a
population-averaged (marginal) rate ratio whereas the mixed model
estimates a physician-conditional one. The one-observation-per-physician
secondary analysis agreed (Kruskal-Wallis H = 97.4, df = 5, p &lt;
0.001); URPS volume exceeded urology and other OB/GYN in pairwise
comparisons (p &lt; 0.001), with no significant URPS-MIGS difference.
Because these models condition on the physician-year being observable
above the CMS reporting threshold, the estimand is annual service volume
among observable physician-years, not full-workforce practice volume; if
non-URPS physicians more often fall below the threshold, the URPS volume
advantage may be overstated.

### Surgeon Volume and Concentration

The primary concentration analysis was within-year. Within-year
concentration was low and stable across the study period: the annual
Gini ranged from 0.26 to 0.28, with no temporal trend (p = 0.451), and
the annual top 20% performed approximately 38% of cases. No
specialty-specific annual Gini changed significantly (all p &gt; 0.15).
Thus, care did not become concentrated among a smaller group of
high-volume surgeons as the observable surgeon pool contracted.

Pooled multi-year concentration was modest for every group: URPS Gini
0.51 (95% CI 0.48-0.53), urology Gini 0.52 (95% CI 0.49-0.55), and other
non-URPS OB/GYN Gini 0.56 (95% CI 0.52-0.60) (Table 2). Because
overlapping individual confidence intervals are not a test of
between-group difference, we bootstrapped the pairwise differences: URPS
and urology did not differ (Gini difference -0.016 (95% CI -0.050 to
+0.021)), whereas URPS was modestly less concentrated than other OB/GYN
(-0.056 (95% CI -0.098 to -0.006), confidence interval excluding zero).
The size-adjusted normalized HHI was near zero for every group (URPS
0.002, urology 0.004, other OB/GYN 0.006 on a 0–1 scale). The effective
number of providers, expressed as a fraction of the actual provider
count, showed a gradient (URPS 305 of 616, 50%; urology 42%; other
OB/GYN 33%), indicating that sling volume was distributed across many
surgeons rather than dominated by a few, though somewhat less evenly in
the smaller groups. Because the specialties differ several-fold in
provider count, raw HHI is not directly comparable across them (Table
2). Adding hypothetical suppressed low-volume providers raised the Gini
(Supplementary Table S8): under the 50% scenario the URPS Gini rose from
0.51 toward the mid-0.6 range, so the sensitivity supports only the
narrower claim that observed services were not dominated by a handful of
surgeons, not a precise estimate of the full-market distribution. URPS
had the highest median annual volume and upper quartile (median 19; p75
29). MIGS was excluded from these comparisons because only 10 physicians
were identified (1–4 per year); its estimates are exploratory.

### Workforce Entry and Exit

Using the two-year washout (Supplementary Table S9), 46–150 surgeons
became newly observable each year and performed 7.4%–21.7% of annual
volume. Their median volume was low, at approximately 13 services,
consistent with surgeons appearing just above the CMS suppression
threshold. Newly observable counts fell to 46 surgeons (7.4% of volume)
in 2020, then rebounded to 150 (21.7%) in 2022; the 2022 rebound may
partly reflect re-observation of surgeons who fell below the threshold
during the pandemic rather than genuinely new surgeons. Continuing
surgeons (357–559 per year) performed most annual services, while
surgeons no longer observable ranged from 64 to 212 per year.

Across the study period, URPS accounted for the most newly observable
episodes (480), followed by urology (165), General OB/GYN (205), and
MIGS (8); these are episode counts, not unique physicians. The rising
URPS share coincided with the largest inflow of newly observable
surgeons together with a relatively stable continuing-URPS base (URPS
surgeon count 304 to 293; per-physician volume unchanged). Urology
showed substantial turnover with net decline, and General OB/GYN
declined in both observable surgeons and market share.

Because total service counts declined, the growth in URPS share
represents a redistribution of a shrinking service pool toward URPS, not
new procedure growth. These transitions describe crossings of the CMS
reporting threshold, not definitive entry into or exit from practice.

Observable surgeons and the URPS share by practice state are reported as
an exploratory secondary analysis in Supplementary Table S7. Because
state-by-sex fee-for-service denominators were not available and CMS
suppression removes low-volume providers, we do not draw access
conclusions from these counts; population-based geographic analysis is
reserved for a separate access-focused study.

## Discussion

This national Medicare analysis produced three main findings. First,
OB/GYN-pathway URPS was the largest single group (55%) and had the
highest adjusted per-physician volume, and the two URPS pathways
together performed the majority (63.7%) of observable services. Second,
the OB/GYN-pathway URPS share increased over the decade, coinciding with
more URPS surgeons becoming observable and fewer non-URPS surgeons
remaining observable, while the urology-pathway URPS share was roughly
stable. Third, surgeon-level concentration remained low and stable
despite a shrinking observable surgeon pool. Together, these findings
indicate a change in the composition of observable fee-for-service
practice rather than intensification of individual practice or
concentration of care; they are best read as a practice-pattern study,
not a study of entry into or exit from the clinical workforce.

### Specialty Distribution and the Historical Reversal

The two URPS pathways together performed approximately three-fifths of
observable fee-for-service Medicare slings (63.7%; OB/GYN pathway 55%,
urology pathway 8.7%), and non-URPS urologists a much smaller share
(14.5%). Because the all-pathway URPS group also includes
urology-trained subspecialists, the URPS share is not equivalent to a
gynecologist share. The apparent non-URPS urology share is sensitive to
classification: a naive provider-type approach that assigns ambulatory
surgical centers and non-physician billers to urology roughly doubles it
(Supplementary Table S11), which likely explains why some earlier
analyses reported a larger urology share. Direct comparison with prior
studies is limited because they used different datasets, specialty
definitions, and care settings. In ACS-NSQIP data from 2006 through
2013, James et al. reported that gynecologists performed 74.2% of sling
procedures and urologists 25.8%;<sup>9</sup> Cantrell et al. found
urogynecologists performed 54% of stress-incontinence procedures at
academic centers from 2009 through 2014;<sup>10</sup> and in Medicare
data from 2002 through 2007, Rogo-Gupta et al. found urologists
performed most sling operations.<sup>11</sup> Rather than asserting a
single historical reversal across these heterogeneous sources, we
conclude more cautiously that OB/GYN-pathway URPS was the largest single
contemporary fee-for-service Medicare group performing this procedure.

Including both certification pathways was essential to this result.
Cross-referencing the ABU roster reassigned 151 urology-typed
physicians, representing 8.7% of all sling procedures, to URPS. The
concentration estimate was robust: the pooled URPS Gini changed only
from 0.51 to 0.52. A pathway-neutral definition also reflects
differences in operative case volume between urology- and
gynecology-based URPS fellowships<sup>14</sup> and variable FPMRS
exposure during urology residency.<sup>15</sup> Classifying
urology-pathway urogynecologists as general urologists would therefore
understate the true subspecialty share.

### Procedural Concentration and the Volume–Outcome Relationship

The Gini coefficient and HHI provide complementary views of
concentration, and both supported the same conclusion. Moderate
inequality across the full distribution (Gini 0.51–0.56, with
overlapping confidence intervals across the well-populated groups)
coexisted with size-adjusted normalized HHI values near zero and
effective provider counts in the hundreds. In other words, sling volume
was distributed unevenly across many surgeons but was not dominated by a
few, and the well-populated specialties did not differ meaningfully in
concentration. Because the physician was the production unit, these
values describe surgeon-level procedural concentration rather than
market competition, and they should not be interpreted using antitrust
thresholds.

These patterns matter because greater surgeon volume has been associated
with better outcomes after midurethral sling surgery. Berger et
al. reported a lower adjusted risk of reoperation for sling failure
among higher-volume surgeons.<sup>16</sup> A systematic review by
Cartier et al. found that low-volume surgeons had higher odds of mesh
revision and repeat incontinence procedures.<sup>17</sup> Brennand and
Quan observed lower revision odds above approximately 50 cases per
year,<sup>18</sup> and Holdø and Svenningsen found better objective cure
rates with greater surgeon experience and annual volume.<sup>19</sup>
The observed fee-for-service Medicare medians of 15–19 services per year
cannot be compared directly with all-payer thresholds such as
approximately 50 operations per year, because the PUF omits commercially
insured, Medicare Advantage, and younger patients and providers below
the CMS suppression threshold; total surgeon experience is therefore
higher than the observed Medicare median, and Medicare PUF volume is an
incomplete proxy for it.

### Temporal Trends, Workforce Dynamics, and the Evolving SUI Landscape

The repeated-measures model and turnover analysis clarify why the URPS
share increased. Individual physician volume did not change over time,
but the number of non-URPS surgeons fell while the URPS pool remained
comparatively stable. URPS also contributed the largest inflow of newly
observable surgeons, whereas urology had substantial turnover but a net
decline. The market-share shift therefore reflects workforce composition
within a shrinking procedure pool, not increasing individual volume or
concentration.

This mechanism is consistent with prior work. Siegal et al. found that
the post-2011 decline in sling placement was driven mainly by non-FPMRS
providers, while FPMRS providers maintained their volumes.<sup>12</sup>
Lee et al. documented an approximately 50% national decline in
incontinence surgery from 2004 through 2013.<sup>13</sup> The 2020
decline in our study (RR 0.88) is consistent with pandemic-related
deferral of elective surgery and remained robust when 2020 was excluded.

The SUI treatment landscape also continues to change. Urethral bulking
agents are now positioned alongside slings as a first-line surgical
option,<sup>3,20</sup> and ongoing surveillance is needed to determine
whether this shift affects specialty-specific sling volume.

### Limitations

This study has five limitations. First, CMS suppresses provider-level
data for fewer than 11 beneficiaries, so the lowest-volume surgeons are
not observed; suppression can bias the Gini coefficient and HHI in
different directions, and the full-market concentration cannot be
identified from the Public Use File, although a sensitivity analysis
adding hypothetical suppressed providers left the low-concentration
conclusion unchanged. Second, the PUF includes only fee-for-service
Medicare Part B claims; younger patients and those covered by Medicare
Advantage, Medicaid, commercial insurance, or no insurance are not
represented.

Third, specialty classification depends on CMS provider type and the
ABOG/ABU rosters. Physicians who completed URPS fellowship but were not
board-certified may therefore be misclassified, and the 323 providers
reclassified from an adjacent provider type to urology could be
misassigned. Fourth, the market-share trend is estimated under plausible
classification scenarios rather than point-identified. Certification
follows the start of subspecialty practice, so the certification-gated
scenario assigns some pre-certification practice years to General OB/GYN
or urology, whereas fixed membership assigns physicians to URPS before
they subspecialized. We present these as plausible scenarios, not formal
bounds; point identification would require unavailable
fellowship-completion dates.

Approximately 8% of URPS physicians could not be matched to a
certification year, and urology-pathway URPS classification remained
fixed because no urology subspecialty date was available; both features
narrow the certification-gated estimate. Fifth, Tot\_Srvcs may include
bilateral or modifier-inflated services.

### Strengths

Strengths include a national sample of all publicly reported,
nonsuppressed fee-for-service provider-service records; identification
of urogynecologists through both certification pathways; complementary
surgeon-level concentration measures with bootstrap confidence
intervals, calculated both overall and by year; models that account for
repeated observations within physicians; transparent handling of
ambiguous and facility billers with sensitivity analyses; and a fully
reproducible analytic pipeline.

## Conclusions

Among observable fee-for-service Medicare claims, the proportion of
sling services for stress urinary incontinence performed by all-pathway
URPS physicians increased between 2013 and 2023, while observable
participation by non-URPS physicians declined. Within-year surgeon-level
concentration remained low and stable and did not differ meaningfully
across the well-populated specialties. Because the data exclude
low-volume physician-years and Medicare Advantage claims and do not
distinguish synthetic midurethral from fascial sling procedures, these
findings describe changes in the observable fee-for-service workforce
rather than the entire national sling market. They may inform workforce
surveillance and fellowship planning; studies linking all-payer volume,
geographic access, and patient outcomes are needed before drawing
credentialing implications.

## References

1.  Wu JM. Stress incontinence in women. N Engl J Med.
    2021;384(25):2428-2436.
2.  Ford AA, Rogerson L, Cody JD, Aluko P, Ogah JA. Mid-urethral sling
    operations for stress urinary incontinence in women. Cochrane
    Database Syst Rev. 2017;7(7):CD006375.
3.  Kobashi KC, Vasavada S, Bloschichak A, et al. Updates to surgical
    treatment of female stress urinary incontinence (SUI): AUA/SUFU
    guideline (2023). J Urol. 2023;209(6):1091-1098.
4.  Birkmeyer JD, Stukel TA, Siewers AE, Goodney PP, Wennberg DE, Lucas
    FL. Surgeon volume and operative mortality in the United States. N
    Engl J Med. 2003;349(22):2117-2127.
5.  Reames BN, Ghaferi AA, Birkmeyer JD, Dimick JB. Hospital volume and
    operative mortality in the modern era. Ann Surg.
    2014;260(2):244-251.
6.  American Board of Medical Specialties. ABMS announces approval of
    new subspecialty certificate in female pelvic medicine and
    reconstructive surgery. 2011. Available at: <https://www.abms.org>.
7.  Berger AA, Tan-Kim J, Menefee SA. The impact of the 2011 US Food and
    Drug Administration transvaginal mesh communication on utilization
    of synthetic mid-urethral sling procedures. Int Urogynecol J.
    2021;32(8):2227-2231.
8.  Stitzenberg KB, Sigurdson ER, Egleston BL, Starkey RB, Meropol NJ.
    Centralization of cancer surgery: implications for patient access to
    optimal care. J Clin Oncol. 2009;27(28):4671-4678.
9.  James MB, Theofanides MC, Sui W, Onyeji I, Badalato GM, Chung DE.
    Sling procedures for the treatment of stress urinary incontinence:
    comparison of national practice patterns between urologists and
    gynecologists. J Urol. 2017;198(6):1386-1391.
10. Cantrell AB, Rothschild J, Durbin-Johnson B, Gonzalez R, Kurzrock
    EA. Surgical trends in the correction of female stress urinary
    incontinence in academic centers within the United States. Neurourol
    Urodyn. 2017;36(2):394-398.
11. Rogo-Gupta L, Litwin MS, Saigal CS, Anger JT; Urologic Diseases in
    America Project. Trends in the surgical management of stress urinary
    incontinence among female Medicare beneficiaries, 2002-2007.
    Urology. 2013;82(1):38-41.
12. Siegal AR, Huang Z, Gross MD, Mehraban-Far S, Weissbart SJ, Kim JM.
    Trends of mesh utilization for stress urinary incontinence before
    and after the 2011 Food and Drug Administration notification between
    FPMRS-certified and non-FPMRS-certified physicians: a statewide
    all-payer database analysis. Urology. 2021;150:151-157.
13. Lee UJ, Feinstein L, Ward JB, et al; Urologic Diseases in America
    Project. National trends in the surgical management of urinary
    incontinence among insured women, 2004 to 2013. J Urol.
    2020;203(2):365-371.
14. Tabakin AL, Sawhney R, Daily AM, Winkler HA, Shalom DF, Tam J,
    Lee W. Case log trends of urogynecology and reconstructive pelvic
    surgery fellows: a comparison of urology- and gynecology-based
    fellowship programs. Neurourol Urodyn. 2024;43(8):1970-1976.
15. Wang CN, Su IW, Smith AL, Badalato GM, Chung DE. Current exposure to
    female pelvic medicine and reconstructive surgery faculty during
    urology residency. Neurourol Urodyn. 2023;42(7):1569-1573.
16. Berger AA, Tan-Kim J, Menefee SA. Surgeon volume and reoperation
    risk after midurethral sling surgery. Am J Obstet Gynecol.
    2019;221(5):523.e1-523.e8.
17. Cartier S, Cerantola GM, Leung AA, Brennand E. The impact of surgeon
    operative volume on risk of reoperation within 5 years of
    mid-urethral sling: a systematic review. Int Urogynecol J.
    2023;34(5):981-992.
18. Brennand EA, Quan H. Evaluation of the effect of surgeon’s operative
    volume and specialty on likelihood of revision after mesh
    midurethral sling placement. Obstet Gynecol. 2019;133(6):1099-1108.
19. Holdø B, Svenningsen R. The impact from surgical experience on
    short- and long-term success rates after mid-urethral sling surgery.
    Int Urogynecol J. 2026 (epub ahead of print).
20. Gallo K, Weiner H, Mishra K. An update on surgical management for
    stress urinary incontinence. Curr Opin Obstet Gynecol.
    2024;36(6):433-438.

------------------------------------------------------------------------

## Tables

**Table 1.** Specialty distribution and market-share trends among
clinicians billing CPT 57288, Medicare PUF 2013–2023, with URPS split by
certification pathway. Δ share is the annual percentage-point change
from ordinary least-squares regression on calendar year.
Specialty-specific physician counts exceed 1,666 because 13 physicians
changed groups across years. \*MIGS estimates are descriptive because
only 10 physicians were identified.

<table>
<colgroup>
<col style="width: 13%" />
<col style="width: 11%" />
<col style="width: 10%" />
<col style="width: 11%" />
<col style="width: 5%" />
<col style="width: 13%" />
<col style="width: 7%" />
<col style="width: 7%" />
<col style="width: 14%" />
<col style="width: 4%" />
</colgroup>
<thead>
<tr>
<th>Specialty</th>
<th>Unique physicians</th>
<th>Physician-years</th>
<th>Reported services</th>
<th>% of all</th>
<th>Median vol (p25-p75)</th>
<th>2013 share</th>
<th>2023 share</th>
<th>Delta share/yr (95% CI)</th>
<th>p</th>
</tr>
</thead>
<tbody>
<tr>
<td>URPS, OB/GYN pathway</td>
<td>616</td>
<td>3,272</td>
<td>77,501</td>
<td>55.0%</td>
<td>19 (14–29)</td>
<td>45.8%</td>
<td>60.6%</td>
<td>+1.42 (1.03 to 1.80)</td>
<td>&lt;0.001</td>
</tr>
<tr>
<td>URPS, urology pathway</td>
<td>151</td>
<td>641</td>
<td>12,272</td>
<td>8.7%</td>
<td>16 (13–22)</td>
<td>9.3%</td>
<td>7.4%</td>
<td>-0.30 (-0.45 to -0.15)</td>
<td>0.001</td>
</tr>
<tr>
<td>Urology (non-URPS)</td>
<td>366</td>
<td>1,150</td>
<td>20,475</td>
<td>14.5%</td>
<td>15 (12–20)</td>
<td>22.4%</td>
<td>8.3%</td>
<td>-1.28 (-1.57 to -0.99)</td>
<td>&lt;0.001</td>
</tr>
<tr>
<td>Other non-URPS OB/GYN</td>
<td>336</td>
<td>953</td>
<td>18,316</td>
<td>13.0%</td>
<td>15 (12–22)</td>
<td>16.3%</td>
<td>13.1%</td>
<td>-0.40 (-0.66 to -0.13)</td>
<td>0.008</td>
</tr>
<tr>
<td>Other/uncertain</td>
<td>200</td>
<td>514</td>
<td>11,504</td>
<td>8.2%</td>
<td>18 (13–27)</td>
<td>6.0%</td>
<td>9.8%</td>
<td>+0.49 (0.33 to 0.64)</td>
<td>&lt;0.001</td>
</tr>
<tr>
<td>MIGS</td>
<td>10</td>
<td>39</td>
<td>941</td>
<td>0.7%</td>
<td>16 (12–24)</td>
<td>0.2%</td>
<td>0.9%</td>
<td>+0.08 (0.03 to 0.12)*</td>
<td>0.004</td>
</tr>
<tr>
<td><strong>Total</strong></td>
<td><strong>1,666</strong></td>
<td><strong>6,569</strong></td>
<td><strong>141,009</strong></td>
<td><strong>100%</strong></td>
<td>n/a</td>
<td>n/a</td>
<td>n/a</td>
<td>n/a</td>
<td>n/a</td>
</tr>
</tbody>
</table>

**Table 2.** Surgeon-level procedural concentration by specialty, based
on aggregate provider volume. Raw HHI is not comparable across groups of
different size; the normalized HHI (0–1) and effective number of
providers are size-adjusted companions.

<table>
<colgroup>
<col style="width: 18%" />
<col style="width: 10%" />
<col style="width: 4%" />
<col style="width: 13%" />
<col style="width: 13%" />
<col style="width: 17%" />
<col style="width: 11%" />
<col style="width: 11%" />
</colgroup>
<thead>
<tr>
<th>Specialty</th>
<th>N providers</th>
<th>Gini</th>
<th>HHI (0-10,000)</th>
<th>Normalized HHI</th>
<th>Effective providers</th>
<th>% by top 10%</th>
<th>% by top 20%</th>
</tr>
</thead>
<tbody>
<tr>
<td>URPS, OB/GYN pathway</td>
<td>616</td>
<td>0.51</td>
<td>33</td>
<td>0.002</td>
<td>305</td>
<td>33.6%</td>
<td>53.0%</td>
</tr>
<tr>
<td>URPS, urology pathway</td>
<td>151</td>
<td>0.53</td>
<td>149</td>
<td>0.008</td>
<td>67</td>
<td>36.2%</td>
<td>56.9%</td>
</tr>
<tr>
<td>Urology (non-URPS)</td>
<td>366</td>
<td>0.52</td>
<td>65</td>
<td>0.004</td>
<td>155</td>
<td>38.6%</td>
<td>58.1%</td>
</tr>
<tr>
<td>Other non-URPS OB/GYN</td>
<td>336</td>
<td>0.56</td>
<td>89</td>
<td>0.006</td>
<td>112</td>
<td>44.4%</td>
<td>62.2%</td>
</tr>
<tr>
<td>MIGS</td>
<td>10</td>
<td>0.61</td>
<td>3,036</td>
<td>0.226</td>
<td>3</td>
<td>49.8%</td>
<td>69.3%</td>
</tr>
</tbody>
</table>

**Table 3.** Adjusted rate ratios for annual reported services from a
Poisson GEE clustered by NPI (OB/GYN-pathway URPS reference; calendar
year centered at 2018; exchangeable correlation; robust standard
errors). The first block gives specialty contrasts at mid-study and the
2020 effect; the second block gives each specialty’s annual trend as a
marginal contrast (the year term plus its specialty-by-year
interaction).

<table>
<colgroup>
<col style="width: 61%" />
<col style="width: 26%" />
<col style="width: 11%" />
</colgroup>
<thead>
<tr>
<th>Term</th>
<th>Rate ratio (95% CI)</th>
<th>p-value</th>
</tr>
</thead>
<tbody>
<tr>
<td>URPS urology vs URPS OB/GYN (at 2018)</td>
<td>0.76 (0.68–0.84)</td>
<td>&lt;0.001</td>
</tr>
<tr>
<td>Non-URPS urology vs URPS OB/GYN (at 2018)</td>
<td>0.71 (0.59–0.85)</td>
<td>&lt;0.001</td>
</tr>
<tr>
<td>Other non-URPS OB/GYN vs URPS OB/GYN (at 2018)</td>
<td>0.63 (0.44–0.90)</td>
<td>0.011</td>
</tr>
<tr>
<td>MIGS vs URPS OB/GYN (at 2018)</td>
<td>0.81 (0.51–1.29)</td>
<td>0.379</td>
</tr>
<tr>
<td>2020 (COVID) indicator</td>
<td>0.88 (0.85–0.91)</td>
<td>&lt;0.001</td>
</tr>
<tr>
<td>Annual trend, URPS (OB/GYN)</td>
<td>0.999 (0.990-1.007)</td>
<td>0.776</td>
</tr>
<tr>
<td>Annual trend, URPS (urology)</td>
<td>0.988 (0.974-1.002)</td>
<td>0.089</td>
</tr>
<tr>
<td>Annual trend, non-URPS urology</td>
<td>0.986 (0.968-1.004)</td>
<td>0.137</td>
</tr>
<tr>
<td>Annual trend, other non-URPS OB/GYN</td>
<td>0.996 (0.973-1.020)</td>
<td>0.760</td>
</tr>
<tr>
<td>Annual trend, MIGS</td>
<td>1.085 (1.031-1.142)</td>
<td>0.002</td>
</tr>
</tbody>
</table>

**Table 4.** All-pathway URPS and OB/GYN-based market-share trends under
alternative classification scenarios. The scenarios differ in the
estimated rate of increase: fixed membership gives the shallower slope
because it counts physicians as URPS before certification, and
certification-gated classification gives the steeper slope because it
removes not-yet-certified physicians from the early URPS count. The 2023
levels converge. These are plausible scenarios rather than formal
statistical bounds. All estimated trends are positive and statistically
significant.

<table>
<colgroup>
<col style="width: 59%" />
<col style="width: 16%" />
<col style="width: 14%" />
<col style="width: 10%" />
</colgroup>
<thead>
<tr>
<th>Analysis</th>
<th>2013 -&gt; 2023</th>
<th>Slope (pp/year)</th>
<th>p-value</th>
</tr>
</thead>
<tbody>
<tr>
<td>Fixed membership: OB/GYN-based share (ABOG-URPS + MIGS + Gen
OB/GYN)</td>
<td>16.5% → 13.9%</td>
<td>-0.32</td>
<td>&lt;0.001</td>
</tr>
<tr>
<td>Fixed membership: all-pathway URPS share</td>
<td>55.1% → 68.0%</td>
<td>1.12</td>
<td>&lt;0.001</td>
</tr>
<tr>
<td>Modal: URPS share</td>
<td>n/a</td>
<td>0.00</td>
<td>&lt;0.001</td>
</tr>
<tr>
<td>Ever-URPS/MIGS: URPS share</td>
<td>n/a</td>
<td>0.00</td>
<td>0.001</td>
</tr>
<tr>
<td><strong>Certification-gated: URPS share (time-varying)</strong></td>
<td><strong>43.6% → 66.9%</strong></td>
<td><strong>1.76</strong></td>
<td><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td>Certification-gated: OB/GYN-based share (time-varying)</td>
<td>n/a</td>
<td>0.79</td>
<td>&lt;0.001</td>
</tr>
</tbody>
</table>

------------------------------------------------------------------------

## Figures

<img
src="/Users/tylermuffly/sling-volume-patterns/output/figures/figure_rate_per_100k.png"
style="width:6.5in" />

**Figure 1.** Utilization of sling surgery for stress urinary
incontinence (CPT 57288) in fee-for-service Medicare, 2013–2023. Bars
show reported services; the line shows the denominator-adjusted rate per
100,000 female Part B fee-for-service beneficiaries. The rate declined
less than the raw count (-15.3% versus -27.7%) because the
fee-for-service population contracted by -14.7%; the linear trend in the
rate was not significant (p = 0.098).

<img
src="/Users/tylermuffly/sling-volume-patterns/output/figures/figure_market_share.png"
style="width:6.5in" />

**Figure 2.** Market share of sling operations for stress urinary
incontinence (CPT 57288) by specialty, fee-for-service Medicare PUF
2013–2023. Stacked areas are the fixed-membership specialty shares; the
two black lines are the URPS share under fixed-membership (solid) and
certification-gated (dashed) classification. Fixed membership
(all-pathway URPS share 55.1% to 68%; +1.12 percentage points/year) and
certification-gated classification (43.6% to 66.9%; +1.76 percentage
points/year) differ in the estimated rate of increase and converge by
2023.

<img
src="/Users/tylermuffly/sling-volume-patterns/output/figures/figure_classification_flow.png"
style="width:6.5in" />

**Figure 3.** Provider-classification flow for CPT 57288. Billers are
assigned to specialty groups by CMS provider type cross-referenced with
the ABOG and ABU rosters. Billers with neither an OB/GYN nor urology CMS
type and no ABOG match (323 NPIs) are predominantly organizations and
non-physician clinicians; organizational NPIs (NPPES entity type 2:
ambulatory surgical centers, hospitals, laboratories; 123) are excluded
and the remaining individual clinicians (200) form an Other/uncertain
group, rather than being counted as urologists. Specialty-specific
counts exceed the analytic cohort because some physicians changed groups
across years.

------------------------------------------------------------------------

## Supplementary Information

Supplementary tables are generated by pipeline step 06 from the same
frozen cache as the main results, so they remain consistent with the
numbers above.

**Supplementary Table S1.** Annual procedural concentration by calendar
year and specialty. Total procedures, observable surgeons, median annual
volume, Gini coefficient, HHI, and top-decile, top-quintile, and
bottom-half shares are reported for every year. Within-year
concentration was low and stable across the study period.

<table>
<colgroup>
<col style="width: 5%" />
<col style="width: 15%" />
<col style="width: 10%" />
<col style="width: 12%" />
<col style="width: 16%" />
<col style="width: 6%" />
<col style="width: 7%" />
<col style="width: 8%" />
<col style="width: 8%" />
<col style="width: 10%" />
</colgroup>
<thead>
<tr>
<th>Year</th>
<th>Specialty</th>
<th>N surgeons</th>
<th>N procedures</th>
<th>Median (p25–p75)</th>
<th>Gini</th>
<th>HHI</th>
<th>Top 10%</th>
<th>Top 20%</th>
<th>Bottom 50%</th>
</tr>
</thead>
<tbody>
<tr>
<td>2013</td>
<td>All</td>
<td>779</td>
<td>15872</td>
<td>16 (13–23)</td>
<td>0.275</td>
<td>17.3</td>
<td>24.4%</td>
<td>39.3%</td>
<td>31.5%</td>
</tr>
<tr>
<td>2013</td>
<td>MIGS</td>
<td>3</td>
<td>35</td>
<td>12 (12–12)</td>
<td>0.019</td>
<td>3338.8</td>
<td>34.3%</td>
<td>34.3%</td>
<td>31.4%</td>
</tr>
<tr>
<td>2013</td>
<td>General OB/GYN</td>
<td>142</td>
<td>2580</td>
<td>14 (12–20)</td>
<td>0.257</td>
<td>93.1</td>
<td>25.2%</td>
<td>39.0%</td>
<td>33.1%</td>
</tr>
<tr>
<td>2013</td>
<td>Urology</td>
<td>211</td>
<td>3563</td>
<td>15 (12–19)</td>
<td>0.198</td>
<td>55.9</td>
<td>20.8%</td>
<td>33.7%</td>
<td>36.3%</td>
</tr>
<tr>
<td>2013</td>
<td>Other/uncertain</td>
<td>38</td>
<td>945</td>
<td>15 (12–35)</td>
<td>0.363</td>
<td>408.8</td>
<td>28.5%</td>
<td>47.4%</td>
<td>25.4%</td>
</tr>
<tr>
<td>2013</td>
<td>URPS (OB/GYN)</td>
<td>304</td>
<td>7266</td>
<td>19 (14–29)</td>
<td>0.294</td>
<td>44.3</td>
<td>24.2%</td>
<td>39.4%</td>
<td>29.8%</td>
</tr>
<tr>
<td>2013</td>
<td>URPS (urology)</td>
<td>81</td>
<td>1483</td>
<td>16 (14–20)</td>
<td>0.199</td>
<td>146.1</td>
<td>22.0%</td>
<td>34.3%</td>
<td>36.2%</td>
</tr>
<tr>
<td>2014</td>
<td>All</td>
<td>656</td>
<td>13725</td>
<td>17 (13–24)</td>
<td>0.269</td>
<td>19.9</td>
<td>23.2%</td>
<td>38.5%</td>
<td>31.6%</td>
</tr>
<tr>
<td>2014</td>
<td>MIGS</td>
<td>3</td>
<td>41</td>
<td>13 (12–15)</td>
<td>0.098</td>
<td>3444.4</td>
<td>41.5%</td>
<td>41.5%</td>
<td>26.8%</td>
</tr>
<tr>
<td>2014</td>
<td>General OB/GYN</td>
<td>114</td>
<td>2076</td>
<td>15 (12–21)</td>
<td>0.239</td>
<td>108.2</td>
<td>22.8%</td>
<td>36.6%</td>
<td>33.6%</td>
</tr>
<tr>
<td>2014</td>
<td>Urology</td>
<td>152</td>
<td>2577</td>
<td>15 (12–19)</td>
<td>0.198</td>
<td>77.1</td>
<td>21.0%</td>
<td>33.6%</td>
<td>36.6%</td>
</tr>
<tr>
<td>2014</td>
<td>Other/uncertain</td>
<td>31</td>
<td>762</td>
<td>19 (12–32)</td>
<td>0.341</td>
<td>479.1</td>
<td>30.7%</td>
<td>45.9%</td>
<td>24.4%</td>
</tr>
<tr>
<td>2014</td>
<td>URPS (OB/GYN)</td>
<td>290</td>
<td>6952</td>
<td>20 (15–30)</td>
<td>0.275</td>
<td>44.8</td>
<td>22.7%</td>
<td>37.8%</td>
<td>30.9%</td>
</tr>
<tr>
<td>2014</td>
<td>URPS (urology)</td>
<td>66</td>
<td>1317</td>
<td>16 (13–23)</td>
<td>0.250</td>
<td>188.7</td>
<td>22.9%</td>
<td>38.6%</td>
<td>32.5%</td>
</tr>
<tr>
<td>2015</td>
<td>All</td>
<td>627</td>
<td>12846</td>
<td>16 (13–24)</td>
<td>0.269</td>
<td>21.1</td>
<td>23.4%</td>
<td>38.4%</td>
<td>31.6%</td>
</tr>
<tr>
<td>2015</td>
<td>MIGS</td>
<td>5</td>
<td>66</td>
<td>12 (11–15)</td>
<td>0.097</td>
<td>2066.1</td>
<td>25.8%</td>
<td>25.8%</td>
<td>33.3%</td>
</tr>
<tr>
<td>2015</td>
<td>General OB/GYN</td>
<td>95</td>
<td>1774</td>
<td>15 (12–20)</td>
<td>0.248</td>
<td>135.5</td>
<td>23.7%</td>
<td>37.8%</td>
<td>33.1%</td>
</tr>
<tr>
<td>2015</td>
<td>Urology</td>
<td>129</td>
<td>2109</td>
<td>14 (12–18)</td>
<td>0.196</td>
<td>92.2</td>
<td>20.2%</td>
<td>33.6%</td>
<td>36.5%</td>
</tr>
<tr>
<td>2015</td>
<td>Other/uncertain</td>
<td>41</td>
<td>979</td>
<td>19 (13–31)</td>
<td>0.309</td>
<td>343.6</td>
<td>27.9%</td>
<td>42.7%</td>
<td>27.6%</td>
</tr>
<tr>
<td>2015</td>
<td>URPS (OB/GYN)</td>
<td>290</td>
<td>6678</td>
<td>19 (14–27)</td>
<td>0.278</td>
<td>45.2</td>
<td>22.9%</td>
<td>38.3%</td>
<td>30.8%</td>
</tr>
<tr>
<td>2015</td>
<td>URPS (urology)</td>
<td>67</td>
<td>1240</td>
<td>15 (12–24)</td>
<td>0.236</td>
<td>185.7</td>
<td>21.5%</td>
<td>36.5%</td>
<td>33.1%</td>
</tr>
<tr>
<td>2016</td>
<td>All</td>
<td>665</td>
<td>14322</td>
<td>18 (13–25)</td>
<td>0.270</td>
<td>19.9</td>
<td>23.8%</td>
<td>38.0%</td>
<td>31.5%</td>
</tr>
<tr>
<td>2016</td>
<td>MIGS</td>
<td>4</td>
<td>62</td>
<td>14 (12–18)</td>
<td>0.161</td>
<td>2731.5</td>
<td>37.1%</td>
<td>37.1%</td>
<td>37.1%</td>
</tr>
<tr>
<td>2016</td>
<td>General OB/GYN</td>
<td>97</td>
<td>1858</td>
<td>15 (13–22)</td>
<td>0.247</td>
<td>133.1</td>
<td>23.1%</td>
<td>37.7%</td>
<td>32.7%</td>
</tr>
<tr>
<td>2016</td>
<td>Urology</td>
<td>129</td>
<td>2225</td>
<td>15 (13–20)</td>
<td>0.199</td>
<td>94.9</td>
<td>20.3%</td>
<td>33.3%</td>
<td>36.3%</td>
</tr>
<tr>
<td>2016</td>
<td>Other/uncertain</td>
<td>49</td>
<td>1072</td>
<td>19 (13–26)</td>
<td>0.269</td>
<td>268.9</td>
<td>22.8%</td>
<td>37.9%</td>
<td>30.4%</td>
</tr>
<tr>
<td>2016</td>
<td>URPS (OB/GYN)</td>
<td>314</td>
<td>7675</td>
<td>20 (14–29)</td>
<td>0.281</td>
<td>41.7</td>
<td>23.4%</td>
<td>38.3%</td>
<td>30.5%</td>
</tr>
<tr>
<td>2016</td>
<td>URPS (urology)</td>
<td>72</td>
<td>1430</td>
<td>16 (14–23)</td>
<td>0.241</td>
<td>181.3</td>
<td>24.3%</td>
<td>37.1%</td>
<td>33.8%</td>
</tr>
<tr>
<td>2017</td>
<td>All</td>
<td>694</td>
<td>15274</td>
<td>18 (13–26)</td>
<td>0.281</td>
<td>19.2</td>
<td>23.8%</td>
<td>38.9%</td>
<td>30.7%</td>
</tr>
<tr>
<td>2017</td>
<td>MIGS</td>
<td>3</td>
<td>79</td>
<td>15 (14–34)</td>
<td>0.338</td>
<td>4923.9</td>
<td>65.8%</td>
<td>65.8%</td>
<td>15.2%</td>
</tr>
<tr>
<td>2017</td>
<td>General OB/GYN</td>
<td>95</td>
<td>1925</td>
<td>16 (13–24)</td>
<td>0.269</td>
<td>143.0</td>
<td>25.4%</td>
<td>38.4%</td>
<td>31.5%</td>
</tr>
<tr>
<td>2017</td>
<td>Urology</td>
<td>126</td>
<td>2341</td>
<td>15 (12–21)</td>
<td>0.249</td>
<td>109.3</td>
<td>24.0%</td>
<td>37.7%</td>
<td>33.3%</td>
</tr>
<tr>
<td>2017</td>
<td>Other/uncertain</td>
<td>55</td>
<td>1189</td>
<td>16 (13–26)</td>
<td>0.286</td>
<td>243.2</td>
<td>25.5%</td>
<td>39.1%</td>
<td>29.4%</td>
</tr>
<tr>
<td>2017</td>
<td>URPS (OB/GYN)</td>
<td>341</td>
<td>8217</td>
<td>20 (14–30)</td>
<td>0.285</td>
<td>38.4</td>
<td>23.0%</td>
<td>38.7%</td>
<td>30.0%</td>
</tr>
<tr>
<td>2017</td>
<td>URPS (urology)</td>
<td>74</td>
<td>1523</td>
<td>17 (14–24)</td>
<td>0.246</td>
<td>169.4</td>
<td>22.9%</td>
<td>36.0%</td>
<td>32.9%</td>
</tr>
<tr>
<td>2018</td>
<td>All</td>
<td>640</td>
<td>14455</td>
<td>19 (14–27)</td>
<td>0.275</td>
<td>20.4</td>
<td>22.9%</td>
<td>37.9%</td>
<td>31.0%</td>
</tr>
<tr>
<td>2018</td>
<td>MIGS</td>
<td>4</td>
<td>126</td>
<td>21 (20–33)</td>
<td>0.278</td>
<td>3445.5</td>
<td>51.6%</td>
<td>51.6%</td>
<td>31.0%</td>
</tr>
<tr>
<td>2018</td>
<td>General OB/GYN</td>
<td>82</td>
<td>1611</td>
<td>18 (13–23)</td>
<td>0.241</td>
<td>155.3</td>
<td>23.5%</td>
<td>36.2%</td>
<td>33.5%</td>
</tr>
<tr>
<td>2018</td>
<td>Urology</td>
<td>112</td>
<td>2195</td>
<td>16 (13–24)</td>
<td>0.257</td>
<td>117.5</td>
<td>23.6%</td>
<td>37.7%</td>
<td>32.3%</td>
</tr>
<tr>
<td>2018</td>
<td>Other/uncertain</td>
<td>55</td>
<td>1284</td>
<td>19 (14–26)</td>
<td>0.275</td>
<td>234.2</td>
<td>24.0%</td>
<td>39.2%</td>
<td>30.5%</td>
</tr>
<tr>
<td>2018</td>
<td>URPS (OB/GYN)</td>
<td>327</td>
<td>8069</td>
<td>21 (15–32)</td>
<td>0.280</td>
<td>39.6</td>
<td>22.3%</td>
<td>37.6%</td>
<td>30.1%</td>
</tr>
<tr>
<td>2018</td>
<td>URPS (urology)</td>
<td>60</td>
<td>1170</td>
<td>16 (14–24)</td>
<td>0.224</td>
<td>202.3</td>
<td>20.1%</td>
<td>34.1%</td>
<td>34.4%</td>
</tr>
<tr>
<td>2019</td>
<td>All</td>
<td>610</td>
<td>13875</td>
<td>19 (14–27)</td>
<td>0.275</td>
<td>21.4</td>
<td>23.4%</td>
<td>38.0%</td>
<td>31.1%</td>
</tr>
<tr>
<td>2019</td>
<td>MIGS</td>
<td>5</td>
<td>168</td>
<td>25 (16–34)</td>
<td>0.333</td>
<td>2913.1</td>
<td>45.8%</td>
<td>45.8%</td>
<td>19.0%</td>
</tr>
<tr>
<td>2019</td>
<td>General OB/GYN</td>
<td>85</td>
<td>1757</td>
<td>17 (13–25)</td>
<td>0.275</td>
<td>156.8</td>
<td>24.6%</td>
<td>38.6%</td>
<td>30.6%</td>
</tr>
<tr>
<td>2019</td>
<td>Urology</td>
<td>82</td>
<td>1621</td>
<td>16 (13–24)</td>
<td>0.239</td>
<td>152.7</td>
<td>22.9%</td>
<td>36.4%</td>
<td>33.5%</td>
</tr>
<tr>
<td>2019</td>
<td>Other/uncertain</td>
<td>52</td>
<td>1155</td>
<td>18 (14–27)</td>
<td>0.271</td>
<td>249.7</td>
<td>25.7%</td>
<td>39.0%</td>
<td>31.2%</td>
</tr>
<tr>
<td>2019</td>
<td>URPS (OB/GYN)</td>
<td>328</td>
<td>8059</td>
<td>20 (15–29)</td>
<td>0.277</td>
<td>39.4</td>
<td>22.7%</td>
<td>38.2%</td>
<td>31.0%</td>
</tr>
<tr>
<td>2019</td>
<td>URPS (urology)</td>
<td>58</td>
<td>1115</td>
<td>16 (13–24)</td>
<td>0.225</td>
<td>215.0</td>
<td>21.3%</td>
<td>35.3%</td>
<td>34.6%</td>
</tr>
<tr>
<td>2020</td>
<td>All</td>
<td>423</td>
<td>8783</td>
<td>17 (13–24)</td>
<td>0.257</td>
<td>30.1</td>
<td>22.9%</td>
<td>37.1%</td>
<td>32.4%</td>
</tr>
<tr>
<td>2020</td>
<td>MIGS</td>
<td>2</td>
<td>81</td>
<td>40 (34–47)</td>
<td>0.154</td>
<td>5476.3</td>
<td>65.4%</td>
<td>65.4%</td>
<td>34.6%</td>
</tr>
<tr>
<td>2020</td>
<td>General OB/GYN</td>
<td>46</td>
<td>941</td>
<td>17 (13–24)</td>
<td>0.250</td>
<td>274.4</td>
<td>23.5%</td>
<td>38.8%</td>
<td>33.3%</td>
</tr>
<tr>
<td>2020</td>
<td>Urology</td>
<td>57</td>
<td>940</td>
<td>14 (12–19)</td>
<td>0.192</td>
<td>204.4</td>
<td>20.2%</td>
<td>34.0%</td>
<td>36.3%</td>
</tr>
<tr>
<td>2020</td>
<td>Other/uncertain</td>
<td>38</td>
<td>770</td>
<td>16 (13–25)</td>
<td>0.234</td>
<td>325.5</td>
<td>21.3%</td>
<td>35.8%</td>
<td>33.5%</td>
</tr>
<tr>
<td>2020</td>
<td>URPS (OB/GYN)</td>
<td>243</td>
<td>5379</td>
<td>19 (14–26)</td>
<td>0.265</td>
<td>52.6</td>
<td>23.1%</td>
<td>37.7%</td>
<td>31.6%</td>
</tr>
<tr>
<td>2020</td>
<td>URPS (urology)</td>
<td>37</td>
<td>672</td>
<td>17 (12–19)</td>
<td>0.216</td>
<td>331.5</td>
<td>22.6%</td>
<td>36.2%</td>
<td>34.4%</td>
</tr>
<tr>
<td>2021</td>
<td>All</td>
<td>429</td>
<td>9020</td>
<td>17 (13–24)</td>
<td>0.266</td>
<td>30.0</td>
<td>22.8%</td>
<td>37.9%</td>
<td>31.6%</td>
</tr>
<tr>
<td>2021</td>
<td>MIGS</td>
<td>3</td>
<td>97</td>
<td>18 (16–41)</td>
<td>0.337</td>
<td>4936.8</td>
<td>66.0%</td>
<td>66.0%</td>
<td>15.5%</td>
</tr>
<tr>
<td>2021</td>
<td>General OB/GYN</td>
<td>58</td>
<td>1076</td>
<td>15 (12–20)</td>
<td>0.268</td>
<td>238.9</td>
<td>25.8%</td>
<td>40.6%</td>
<td>32.6%</td>
</tr>
<tr>
<td>2021</td>
<td>Urology</td>
<td>42</td>
<td>764</td>
<td>16 (13–23)</td>
<td>0.207</td>
<td>274.6</td>
<td>21.9%</td>
<td>34.8%</td>
<td>35.5%</td>
</tr>
<tr>
<td>2021</td>
<td>Other/uncertain</td>
<td>44</td>
<td>969</td>
<td>18 (14–28)</td>
<td>0.237</td>
<td>269.5</td>
<td>20.9%</td>
<td>35.2%</td>
<td>32.9%</td>
</tr>
<tr>
<td>2021</td>
<td>URPS (OB/GYN)</td>
<td>250</td>
<td>5523</td>
<td>18 (14–27)</td>
<td>0.271</td>
<td>51.3</td>
<td>22.6%</td>
<td>38.0%</td>
<td>31.3%</td>
</tr>
<tr>
<td>2021</td>
<td>URPS (urology)</td>
<td>32</td>
<td>591</td>
<td>16 (12–20)</td>
<td>0.234</td>
<td>397.4</td>
<td>26.1%</td>
<td>38.1%</td>
<td>33.8%</td>
</tr>
<tr>
<td>2022</td>
<td>All</td>
<td>524</td>
<td>11367</td>
<td>17 (14–26)</td>
<td>0.275</td>
<td>25.2</td>
<td>24.0%</td>
<td>38.9%</td>
<td>31.3%</td>
</tr>
<tr>
<td>2022</td>
<td>MIGS</td>
<td>3</td>
<td>87</td>
<td>17 (14–38)</td>
<td>0.352</td>
<td>5016.5</td>
<td>66.7%</td>
<td>66.7%</td>
<td>13.8%</td>
</tr>
<tr>
<td>2022</td>
<td>General OB/GYN</td>
<td>63</td>
<td>1218</td>
<td>15 (13–21)</td>
<td>0.257</td>
<td>206.2</td>
<td>25.5%</td>
<td>39.0%</td>
<td>32.2%</td>
</tr>
<tr>
<td>2022</td>
<td>Urology</td>
<td>62</td>
<td>1192</td>
<td>17 (13–22)</td>
<td>0.223</td>
<td>195.4</td>
<td>22.1%</td>
<td>35.8%</td>
<td>34.9%</td>
</tr>
<tr>
<td>2022</td>
<td>Other/uncertain</td>
<td>55</td>
<td>1258</td>
<td>17 (14–32)</td>
<td>0.282</td>
<td>235.3</td>
<td>23.9%</td>
<td>38.3%</td>
<td>29.3%</td>
</tr>
<tr>
<td>2022</td>
<td>URPS (OB/GYN)</td>
<td>292</td>
<td>6734</td>
<td>19 (14–27)</td>
<td>0.287</td>
<td>45.7</td>
<td>24.2%</td>
<td>39.7%</td>
<td>30.4%</td>
</tr>
<tr>
<td>2022</td>
<td>URPS (urology)</td>
<td>49</td>
<td>878</td>
<td>16 (13–20)</td>
<td>0.194</td>
<td>239.3</td>
<td>20.0%</td>
<td>33.1%</td>
<td>36.3%</td>
</tr>
<tr>
<td>2023</td>
<td>All</td>
<td>522</td>
<td>11470</td>
<td>18 (14–26)</td>
<td>0.267</td>
<td>24.6</td>
<td>22.9%</td>
<td>37.8%</td>
<td>31.6%</td>
</tr>
<tr>
<td>2023</td>
<td>MIGS</td>
<td>4</td>
<td>99</td>
<td>14 (12–27)</td>
<td>0.381</td>
<td>4204.7</td>
<td>60.6%</td>
<td>60.6%</td>
<td>23.2%</td>
</tr>
<tr>
<td>2023</td>
<td>General OB/GYN</td>
<td>76</td>
<td>1500</td>
<td>16 (13–23)</td>
<td>0.248</td>
<td>163.9</td>
<td>22.7%</td>
<td>37.7%</td>
<td>32.7%</td>
</tr>
<tr>
<td>2023</td>
<td>Urology</td>
<td>48</td>
<td>948</td>
<td>17 (13–23)</td>
<td>0.236</td>
<td>253.9</td>
<td>20.9%</td>
<td>35.9%</td>
<td>33.3%</td>
</tr>
<tr>
<td>2023</td>
<td>Other/uncertain</td>
<td>56</td>
<td>1121</td>
<td>16 (13–25)</td>
<td>0.242</td>
<td>218.0</td>
<td>21.6%</td>
<td>36.6%</td>
<td>32.3%</td>
</tr>
<tr>
<td>2023</td>
<td>URPS (OB/GYN)</td>
<td>293</td>
<td>6949</td>
<td>20 (15–28)</td>
<td>0.275</td>
<td>44.2</td>
<td>23.1%</td>
<td>38.4%</td>
<td>31.0%</td>
</tr>
<tr>
<td>2023</td>
<td>URPS (urology)</td>
<td>45</td>
<td>853</td>
<td>16 (12–23)</td>
<td>0.227</td>
<td>264.9</td>
<td>21.7%</td>
<td>34.2%</td>
<td>33.1%</td>
</tr>
</tbody>
</table>

**Supplementary Table S2.** Trend regressions for annual concentration
and volume measures on calendar year, overall and by specialty (ordinary
least squares).

<table>
<colgroup>
<col style="width: 25%" />
<col style="width: 17%" />
<col style="width: 11%" />
<col style="width: 11%" />
<col style="width: 14%" />
<col style="width: 11%" />
<col style="width: 9%" />
</colgroup>
<thead>
<tr>
<th>Measure</th>
<th>Specialty</th>
<th>Start</th>
<th>End</th>
<th>Slope / year</th>
<th>R-squared</th>
<th>p-value</th>
</tr>
</thead>
<tbody>
<tr>
<td>Total procedures</td>
<td>All</td>
<td>15872.000</td>
<td>11470.000</td>
<td>-503.609</td>
<td>0.491</td>
<td>0.020</td>
</tr>
<tr>
<td>Total procedures</td>
<td>General OB/GYN</td>
<td>2580.000</td>
<td>1500.000</td>
<td>-117.527</td>
<td>0.681</td>
<td>0.002</td>
</tr>
<tr>
<td>Total procedures</td>
<td>MIGS</td>
<td>35.000</td>
<td>99.000</td>
<td>6.582</td>
<td>0.333</td>
<td>0.060</td>
</tr>
<tr>
<td>Total procedures</td>
<td>Other/uncertain</td>
<td>945.000</td>
<td>1121.000</td>
<td>19.964</td>
<td>0.138</td>
<td>0.260</td>
</tr>
<tr>
<td>Total procedures</td>
<td>URPS (OB/GYN)</td>
<td>7266.000</td>
<td>6949.000</td>
<td>-97.018</td>
<td>0.112</td>
<td>0.310</td>
</tr>
<tr>
<td>Total procedures</td>
<td>URPS (urology)</td>
<td>1483.000</td>
<td>853.000</td>
<td>-79.791</td>
<td>0.663</td>
<td>0.002</td>
</tr>
<tr>
<td>Total procedures</td>
<td>Urology</td>
<td>3563.000</td>
<td>948.000</td>
<td>-235.818</td>
<td>0.834</td>
<td>n/a</td>
</tr>
<tr>
<td>Observable surgeons</td>
<td>All</td>
<td>779.000</td>
<td>522.000</td>
<td>-27.045</td>
<td>0.654</td>
<td>0.003</td>
</tr>
<tr>
<td>Observable surgeons</td>
<td>General OB/GYN</td>
<td>142.000</td>
<td>76.000</td>
<td>-6.882</td>
<td>0.721</td>
<td>n/a</td>
</tr>
<tr>
<td>Observable surgeons</td>
<td>MIGS</td>
<td>3.000</td>
<td>4.000</td>
<td>-0.027</td>
<td>0.009</td>
<td>0.780</td>
</tr>
<tr>
<td>Observable surgeons</td>
<td>Other/uncertain</td>
<td>38.000</td>
<td>56.000</td>
<td>1.545</td>
<td>0.344</td>
<td>0.060</td>
</tr>
<tr>
<td>Observable surgeons</td>
<td>URPS (OB/GYN)</td>
<td>304.000</td>
<td>293.000</td>
<td>-2.927</td>
<td>0.100</td>
<td>0.340</td>
</tr>
<tr>
<td>Observable surgeons</td>
<td>URPS (urology)</td>
<td>81.000</td>
<td>45.000</td>
<td>-3.991</td>
<td>0.702</td>
<td>0.001</td>
</tr>
<tr>
<td>Observable surgeons</td>
<td>Urology</td>
<td>211.000</td>
<td>48.000</td>
<td>-14.764</td>
<td>0.889</td>
<td>n/a</td>
</tr>
<tr>
<td>Median annual volume</td>
<td>All</td>
<td>16.000</td>
<td>18.000</td>
<td>0.109</td>
<td>0.122</td>
<td>0.290</td>
</tr>
<tr>
<td>Median annual volume</td>
<td>General OB/GYN</td>
<td>14.000</td>
<td>16.000</td>
<td>0.136</td>
<td>0.169</td>
<td>0.210</td>
</tr>
<tr>
<td>Median annual volume</td>
<td>MIGS</td>
<td>12.000</td>
<td>14.000</td>
<td>0.973</td>
<td>0.148</td>
<td>0.240</td>
</tr>
<tr>
<td>Median annual volume</td>
<td>Other/uncertain</td>
<td>15.000</td>
<td>16.000</td>
<td>-0.064</td>
<td>0.019</td>
<td>0.680</td>
</tr>
<tr>
<td>Median annual volume</td>
<td>URPS (OB/GYN)</td>
<td>19.000</td>
<td>20.000</td>
<td>-0.036</td>
<td>0.022</td>
<td>0.670</td>
</tr>
<tr>
<td>Median annual volume</td>
<td>URPS (urology)</td>
<td>16.000</td>
<td>16.000</td>
<td>0.036</td>
<td>0.036</td>
<td>0.580</td>
</tr>
<tr>
<td>Median annual volume</td>
<td>Urology</td>
<td>15.000</td>
<td>17.000</td>
<td>0.209</td>
<td>0.462</td>
<td>0.020</td>
</tr>
<tr>
<td>Gini coefficient</td>
<td>All</td>
<td>0.275</td>
<td>0.267</td>
<td>0.000</td>
<td>0.064</td>
<td>0.450</td>
</tr>
<tr>
<td>Gini coefficient</td>
<td>General OB/GYN</td>
<td>0.257</td>
<td>0.248</td>
<td>0.001</td>
<td>0.064</td>
<td>0.450</td>
</tr>
<tr>
<td>Gini coefficient</td>
<td>MIGS</td>
<td>0.019</td>
<td>0.381</td>
<td>0.032</td>
<td>0.692</td>
<td>0.002</td>
</tr>
<tr>
<td>Gini coefficient</td>
<td>Other/uncertain</td>
<td>0.363</td>
<td>0.242</td>
<td>-0.010</td>
<td>0.700</td>
<td>0.001</td>
</tr>
<tr>
<td>Gini coefficient</td>
<td>URPS (OB/GYN)</td>
<td>0.294</td>
<td>0.275</td>
<td>-0.001</td>
<td>0.177</td>
<td>0.200</td>
</tr>
<tr>
<td>Gini coefficient</td>
<td>URPS (urology)</td>
<td>0.199</td>
<td>0.227</td>
<td>-0.001</td>
<td>0.070</td>
<td>0.430</td>
</tr>
<tr>
<td>Gini coefficient</td>
<td>Urology</td>
<td>0.198</td>
<td>0.236</td>
<td>0.003</td>
<td>0.139</td>
<td>0.260</td>
</tr>
<tr>
<td>HHI (0–10,000)</td>
<td>All</td>
<td>17.307</td>
<td>24.632</td>
<td>0.973</td>
<td>0.564</td>
<td>0.008</td>
</tr>
<tr>
<td>HHI (0–10,000)</td>
<td>General OB/GYN</td>
<td>93.149</td>
<td>163.902</td>
<td>12.294</td>
<td>0.553</td>
<td>0.009</td>
</tr>
<tr>
<td>HHI (0–10,000)</td>
<td>MIGS</td>
<td>3338.776</td>
<td>4204.673</td>
<td>206.443</td>
<td>0.379</td>
<td>0.040</td>
</tr>
<tr>
<td>HHI (0–10,000)</td>
<td>Other/uncertain</td>
<td>408.846</td>
<td>217.954</td>
<td>-18.475</td>
<td>0.542</td>
<td>0.010</td>
</tr>
<tr>
<td>HHI (0–10,000)</td>
<td>URPS (OB/GYN)</td>
<td>44.322</td>
<td>44.229</td>
<td>0.404</td>
<td>0.085</td>
<td>0.380</td>
</tr>
<tr>
<td>HHI (0–10,000)</td>
<td>URPS (urology)</td>
<td>146.115</td>
<td>264.909</td>
<td>16.159</td>
<td>0.501</td>
<td>0.010</td>
</tr>
<tr>
<td>HHI (0–10,000)</td>
<td>Urology</td>
<td>55.876</td>
<td>253.877</td>
<td>20.658</td>
<td>0.861</td>
<td>n/a</td>
</tr>
<tr>
<td>Share by top 10% (%)</td>
<td>All</td>
<td>24.427</td>
<td>22.903</td>
<td>-0.080</td>
<td>0.247</td>
<td>0.120</td>
</tr>
<tr>
<td>Share by top 10% (%)</td>
<td>General OB/GYN</td>
<td>25.194</td>
<td>22.733</td>
<td>0.045</td>
<td>0.016</td>
<td>0.710</td>
</tr>
<tr>
<td>Share by top 10% (%)</td>
<td>MIGS</td>
<td>34.286</td>
<td>60.606</td>
<td>3.543</td>
<td>0.623</td>
<td>0.004</td>
</tr>
<tr>
<td>Share by top 10% (%)</td>
<td>Other/uncertain</td>
<td>28.466</td>
<td>21.588</td>
<td>-0.773</td>
<td>0.643</td>
<td>0.003</td>
</tr>
<tr>
<td>Share by top 10% (%)</td>
<td>URPS (OB/GYN)</td>
<td>24.250</td>
<td>23.097</td>
<td>-0.016</td>
<td>0.007</td>
<td>0.800</td>
</tr>
<tr>
<td>Share by top 10% (%)</td>
<td>URPS (urology)</td>
<td>21.982</td>
<td>21.688</td>
<td>-0.036</td>
<td>0.005</td>
<td>0.840</td>
</tr>
<tr>
<td>Share by top 10% (%)</td>
<td>Urology</td>
<td>20.797</td>
<td>20.886</td>
<td>0.082</td>
<td>0.039</td>
<td>0.560</td>
</tr>
<tr>
<td>Share by top 20% (%)</td>
<td>All</td>
<td>39.308</td>
<td>37.751</td>
<td>-0.092</td>
<td>0.246</td>
<td>0.120</td>
</tr>
<tr>
<td>Share by top 20% (%)</td>
<td>General OB/GYN</td>
<td>39.031</td>
<td>37.667</td>
<td>0.124</td>
<td>0.113</td>
<td>0.310</td>
</tr>
<tr>
<td>Share by top 20% (%)</td>
<td>MIGS</td>
<td>34.286</td>
<td>60.606</td>
<td>3.543</td>
<td>0.623</td>
<td>0.004</td>
</tr>
<tr>
<td>Share by top 20% (%)</td>
<td>Other/uncertain</td>
<td>47.407</td>
<td>36.574</td>
<td>-1.012</td>
<td>0.710</td>
<td>0.001</td>
</tr>
<tr>
<td>Share by top 20% (%)</td>
<td>URPS (OB/GYN)</td>
<td>39.403</td>
<td>38.365</td>
<td>-0.004</td>
<td>0.000</td>
<td>0.950</td>
</tr>
<tr>
<td>Share by top 20% (%)</td>
<td>URPS (urology)</td>
<td>34.322</td>
<td>34.232</td>
<td>-0.185</td>
<td>0.123</td>
<td>0.290</td>
</tr>
<tr>
<td>Share by top 20% (%)</td>
<td>Urology</td>
<td>33.679</td>
<td>35.865</td>
<td>0.215</td>
<td>0.189</td>
<td>0.180</td>
</tr>
<tr>
<td>Share by bottom 50% (%)</td>
<td>All</td>
<td>31.496</td>
<td>31.569</td>
<td>0.015</td>
<td>0.013</td>
<td>0.740</td>
</tr>
<tr>
<td>Share by bottom 50% (%)</td>
<td>General OB/GYN</td>
<td>33.062</td>
<td>32.667</td>
<td>-0.081</td>
<td>0.090</td>
<td>0.370</td>
</tr>
<tr>
<td>Share by bottom 50% (%)</td>
<td>MIGS</td>
<td>31.429</td>
<td>23.232</td>
<td>-1.345</td>
<td>0.270</td>
<td>0.100</td>
</tr>
<tr>
<td>Share by bottom 50% (%)</td>
<td>Other/uncertain</td>
<td>25.397</td>
<td>32.293</td>
<td>0.710</td>
<td>0.644</td>
<td>0.003</td>
</tr>
<tr>
<td>Share by bottom 50% (%)</td>
<td>URPS (OB/GYN)</td>
<td>29.769</td>
<td>31.026</td>
<td>0.084</td>
<td>0.233</td>
<td>0.130</td>
</tr>
<tr>
<td>Share by bottom 50% (%)</td>
<td>URPS (urology)</td>
<td>36.210</td>
<td>33.060</td>
<td>0.043</td>
<td>0.012</td>
<td>0.740</td>
</tr>
<tr>
<td>Share by bottom 50% (%)</td>
<td>Urology</td>
<td>36.290</td>
<td>33.333</td>
<td>-0.220</td>
<td>0.216</td>
<td>0.150</td>
</tr>
</tbody>
</table>

**Supplementary Table S3.** Specialty-specific market-share trends. Each
specialty’s annual share of observed procedures is regressed on calendar
year separately (fixed-membership classification).

<table>
<colgroup>
<col style="width: 23%" />
<col style="width: 21%" />
<col style="width: 21%" />
<col style="width: 20%" />
<col style="width: 12%" />
</colgroup>
<thead>
<tr>
<th>Specialty</th>
<th>2013 share (%)</th>
<th>2023 share (%)</th>
<th>Slope (pp/yr)</th>
<th>p-value</th>
</tr>
</thead>
<tbody>
<tr>
<td>General OB/GYN</td>
<td>16.3</td>
<td>13.1</td>
<td>-0.397</td>
<td>0.008</td>
</tr>
<tr>
<td>MIGS</td>
<td>0.2</td>
<td>0.9</td>
<td>0.077</td>
<td>0.004</td>
</tr>
<tr>
<td>Other/uncertain</td>
<td>6.0</td>
<td>9.8</td>
<td>0.488</td>
<td>&lt;0.001</td>
</tr>
<tr>
<td>URPS (OB/GYN)</td>
<td>45.8</td>
<td>60.6</td>
<td>1.416</td>
<td>&lt;0.001</td>
</tr>
<tr>
<td>URPS (urology)</td>
<td>9.3</td>
<td>7.4</td>
<td>-0.299</td>
<td>0.001</td>
</tr>
<tr>
<td>Urology</td>
<td>22.4</td>
<td>8.3</td>
<td>-1.284</td>
<td>&lt;0.001</td>
</tr>
</tbody>
</table>

**Supplementary Table S4.** Adjusted rate ratios for annual sling volume
from a Poisson GEE clustered by NPI, excluding calendar year 2020
(COVID-19 sensitivity analysis; URPS reference).

<table>
<thead>
<tr>
<th>Term</th>
<th>RR (95% CI)</th>
<th>p-value</th>
</tr>
</thead>
<tbody>
<tr>
<td>(Intercept)</td>
<td>21.79 (20.23-23.48)</td>
<td>n/a</td>
</tr>
<tr>
<td>Specialty: General OB/GYN</td>
<td>0.64 (0.46-0.90)</td>
<td>0.010</td>
</tr>
<tr>
<td>Specialty: MIGS</td>
<td>0.88 (0.58-1.34)</td>
<td>0.540</td>
</tr>
<tr>
<td>Specialty: Other/uncertain</td>
<td>0.89 (0.80-0.98)</td>
<td>0.020</td>
</tr>
<tr>
<td>Specialty: Urology</td>
<td>0.69 (0.57-0.83)</td>
<td>n/a</td>
</tr>
<tr>
<td>Specialty: URPS (urology)</td>
<td>0.75 (0.68-0.83)</td>
<td>n/a</td>
</tr>
<tr>
<td>year_c</td>
<td>1.00 (0.99-1.01)</td>
<td>0.850</td>
</tr>
<tr>
<td>Specialty: General OB/GYN:year_c</td>
<td>1.00 (0.97-1.02)</td>
<td>0.900</td>
</tr>
<tr>
<td>Specialty: MIGS:year_c</td>
<td>1.08 (1.02-1.14)</td>
<td>0.006</td>
</tr>
<tr>
<td>Specialty: Other/uncertain:year_c</td>
<td>0.99 (0.95-1.03)</td>
<td>0.550</td>
</tr>
<tr>
<td>Specialty: Urology:year_c</td>
<td>0.99 (0.97-1.01)</td>
<td>0.230</td>
</tr>
<tr>
<td>Specialty: URPS (urology):year_c</td>
<td>0.99 (0.97-1.01)</td>
<td>0.210</td>
</tr>
</tbody>
</table>

**Supplementary Table S5.** Per-physician volume comparisons (one median
value per physician), Kruskal-Wallis and pairwise Wilcoxon tests with
Bonferroni correction.

<table>
<colgroup>
<col style="width: 75%" />
<col style="width: 11%" />
<col style="width: 4%" />
<col style="width: 9%" />
</colgroup>
<thead>
<tr>
<th>Test</th>
<th>Statistic</th>
<th>df</th>
<th>p-value</th>
</tr>
</thead>
<tbody>
<tr>
<td>Kruskal-Wallis: per-physician median volume across specialties</td>
<td>97.35</td>
<td>5</td>
<td>&lt;0.001</td>
</tr>
<tr>
<td>Wilcoxon (per-physician, bonferroni): MIGS vs General OB/GYN</td>
<td>n/a</td>
<td>NA</td>
<td>1.00</td>
</tr>
<tr>
<td>Wilcoxon (per-physician, bonferroni): Other/uncertain vs General
OB/GYN</td>
<td>n/a</td>
<td>NA</td>
<td>0.002</td>
</tr>
<tr>
<td>Wilcoxon (per-physician, bonferroni): Other/uncertain vs MIGS</td>
<td>n/a</td>
<td>NA</td>
<td>1.00</td>
</tr>
<tr>
<td>Wilcoxon (per-physician, bonferroni): Urology vs General OB/GYN</td>
<td>n/a</td>
<td>NA</td>
<td>1.00</td>
</tr>
<tr>
<td>Wilcoxon (per-physician, bonferroni): Urology vs MIGS</td>
<td>n/a</td>
<td>NA</td>
<td>1.00</td>
</tr>
<tr>
<td>Wilcoxon (per-physician, bonferroni): Urology vs
Other/uncertain</td>
<td>n/a</td>
<td>NA</td>
<td>&lt;0.001</td>
</tr>
<tr>
<td>Wilcoxon (per-physician, bonferroni): URPS (OB/GYN) vs General
OB/GYN</td>
<td>n/a</td>
<td>NA</td>
<td>&lt;0.001</td>
</tr>
<tr>
<td>Wilcoxon (per-physician, bonferroni): URPS (OB/GYN) vs MIGS</td>
<td>n/a</td>
<td>NA</td>
<td>1.00</td>
</tr>
<tr>
<td>Wilcoxon (per-physician, bonferroni): URPS (OB/GYN) vs
Other/uncertain</td>
<td>n/a</td>
<td>NA</td>
<td>1.00</td>
</tr>
<tr>
<td>Wilcoxon (per-physician, bonferroni): URPS (OB/GYN) vs Urology</td>
<td>n/a</td>
<td>NA</td>
<td>&lt;0.001</td>
</tr>
<tr>
<td>Wilcoxon (per-physician, bonferroni): URPS (urology) vs General
OB/GYN</td>
<td>n/a</td>
<td>NA</td>
<td>1.00</td>
</tr>
<tr>
<td>Wilcoxon (per-physician, bonferroni): URPS (urology) vs MIGS</td>
<td>n/a</td>
<td>NA</td>
<td>1.00</td>
</tr>
<tr>
<td>Wilcoxon (per-physician, bonferroni): URPS (urology) vs
Other/uncertain</td>
<td>n/a</td>
<td>NA</td>
<td>0.76</td>
</tr>
<tr>
<td>Wilcoxon (per-physician, bonferroni): URPS (urology) vs Urology</td>
<td>n/a</td>
<td>NA</td>
<td>0.86</td>
</tr>
<tr>
<td>Wilcoxon (per-physician, bonferroni): URPS (urology) vs URPS
(OB/GYN)</td>
<td>n/a</td>
<td>NA</td>
<td>&lt;0.001</td>
</tr>
</tbody>
</table>

**Supplementary Table S6a.** Specialty distribution under alternative
classification schemes (time-varying, modal, ever-URPS/MIGS,
certification-gated).

<table>
<colgroup>
<col style="width: 46%" />
<col style="width: 17%" />
<col style="width: 13%" />
<col style="width: 12%" />
<col style="width: 10%" />
</colgroup>
<thead>
<tr>
<th>Scheme</th>
<th>Specialty</th>
<th>N providers</th>
<th>Procedures</th>
<th>% of all</th>
</tr>
</thead>
<tbody>
<tr>
<td>Time-varying (per physician-year)</td>
<td>General OB/GYN</td>
<td>336</td>
<td>18316</td>
<td>13.0%</td>
</tr>
<tr>
<td>Time-varying (per physician-year)</td>
<td>MIGS</td>
<td>10</td>
<td>941</td>
<td>0.7%</td>
</tr>
<tr>
<td>Time-varying (per physician-year)</td>
<td>Other/uncertain</td>
<td>200</td>
<td>11504</td>
<td>8.2%</td>
</tr>
<tr>
<td>Time-varying (per physician-year)</td>
<td>URPS</td>
<td>767</td>
<td>89773</td>
<td>63.7%</td>
</tr>
<tr>
<td>Time-varying (per physician-year)</td>
<td>Urology</td>
<td>366</td>
<td>20475</td>
<td>14.5%</td>
</tr>
<tr>
<td>Modal (single most-frequent specialty)</td>
<td>General OB/GYN</td>
<td>332</td>
<td>18287</td>
<td>13.0%</td>
</tr>
<tr>
<td>Modal (single most-frequent specialty)</td>
<td>MIGS</td>
<td>10</td>
<td>941</td>
<td>0.7%</td>
</tr>
<tr>
<td>Modal (single most-frequent specialty)</td>
<td>Other/uncertain</td>
<td>200</td>
<td>11504</td>
<td>8.2%</td>
</tr>
<tr>
<td>Modal (single most-frequent specialty)</td>
<td>URPS</td>
<td>766</td>
<td>90107</td>
<td>63.9%</td>
</tr>
<tr>
<td>Modal (single most-frequent specialty)</td>
<td>Urology</td>
<td>358</td>
<td>20170</td>
<td>14.3%</td>
</tr>
<tr>
<td>Ever URPS/MIGS</td>
<td>General OB/GYN</td>
<td>332</td>
<td>18287</td>
<td>13.0%</td>
</tr>
<tr>
<td>Ever URPS/MIGS</td>
<td>MIGS</td>
<td>10</td>
<td>941</td>
<td>0.7%</td>
</tr>
<tr>
<td>Ever URPS/MIGS</td>
<td>Other/uncertain</td>
<td>200</td>
<td>11504</td>
<td>8.2%</td>
</tr>
<tr>
<td>Ever URPS/MIGS</td>
<td>URPS</td>
<td>767</td>
<td>90686</td>
<td>64.3%</td>
</tr>
<tr>
<td>Ever URPS/MIGS</td>
<td>Urology</td>
<td>357</td>
<td>19591</td>
<td>13.9%</td>
</tr>
<tr>
<td>Time-varying cert-gated (ABOG sub1startdate)</td>
<td>General OB/GYN</td>
<td>533</td>
<td>27453</td>
<td>19.5%</td>
</tr>
<tr>
<td>Time-varying cert-gated (ABOG sub1startdate)</td>
<td>MIGS</td>
<td>5</td>
<td>201</td>
<td>0.1%</td>
</tr>
<tr>
<td>Time-varying cert-gated (ABOG sub1startdate)</td>
<td>Other/uncertain</td>
<td>200</td>
<td>11492</td>
<td>8.1%</td>
</tr>
<tr>
<td>Time-varying cert-gated (ABOG sub1startdate)</td>
<td>URPS</td>
<td>716</td>
<td>83348</td>
<td>59.1%</td>
</tr>
<tr>
<td>Time-varying cert-gated (ABOG sub1startdate)</td>
<td>Urology</td>
<td>353</td>
<td>18515</td>
<td>13.1%</td>
</tr>
</tbody>
</table>

**Supplementary Table S6b.** All-pathway URPS and OB/GYN-based
market-share trends under each classification scheme. The URPS increase
remains positive and significant in every scheme.

<table style="width:100%;">
<colgroup>
<col style="width: 45%" />
<col style="width: 19%" />
<col style="width: 7%" />
<col style="width: 18%" />
<col style="width: 7%" />
</colgroup>
<thead>
<tr>
<th>Scheme</th>
<th>URPS slope (pp/yr)</th>
<th>URPS p</th>
<th>Gyn slope (pp/yr)</th>
<th>Gyn p</th>
</tr>
</thead>
<tbody>
<tr>
<td>Time-varying (per physician-year)</td>
<td>1.116</td>
<td>&lt;0.001</td>
<td>0.796</td>
<td>&lt;0.001</td>
</tr>
<tr>
<td>Modal (single most-frequent specialty)</td>
<td>1.200</td>
<td>&lt;0.001</td>
<td>0.906</td>
<td>&lt;0.001</td>
</tr>
<tr>
<td>Ever URPS/MIGS</td>
<td>1.174</td>
<td>&lt;0.001</td>
<td>0.881</td>
<td>&lt;0.001</td>
</tr>
<tr>
<td>Time-varying cert-gated (ABOG sub1startdate)</td>
<td>1.762</td>
<td>&lt;0.001</td>
<td>0.792</td>
<td>&lt;0.001</td>
</tr>
</tbody>
</table>

**Supplementary Table S7.** Observable surgeons and URPS share by
provider practice state (geography, secondary analysis). A state with no
observable URPS surgeon may still have URPS surgeons who each fell below
the CMS reporting threshold.

<table style="width:100%;">
<colgroup>
<col style="width: 9%" />
<col style="width: 28%" />
<col style="width: 20%" />
<col style="width: 16%" />
<col style="width: 24%" />
</colgroup>
<thead>
<tr>
<th>State</th>
<th>Observable surgeons</th>
<th>URPS surgeons</th>
<th>URPS share</th>
<th>Observable URPS?</th>
</tr>
</thead>
<tbody>
<tr>
<td>CA</td>
<td>138</td>
<td>50</td>
<td>36.2%</td>
<td>Yes</td>
</tr>
<tr>
<td>TX</td>
<td>133</td>
<td>47</td>
<td>35.3%</td>
<td>Yes</td>
</tr>
<tr>
<td>FL</td>
<td>127</td>
<td>49</td>
<td>38.6%</td>
<td>Yes</td>
</tr>
<tr>
<td>NY</td>
<td>70</td>
<td>41</td>
<td>58.6%</td>
<td>Yes</td>
</tr>
<tr>
<td>IL</td>
<td>62</td>
<td>39</td>
<td>62.9%</td>
<td>Yes</td>
</tr>
<tr>
<td>OH</td>
<td>59</td>
<td>44</td>
<td>74.6%</td>
<td>Yes</td>
</tr>
<tr>
<td>PA</td>
<td>57</td>
<td>33</td>
<td>57.9%</td>
<td>Yes</td>
</tr>
<tr>
<td>AZ</td>
<td>55</td>
<td>19</td>
<td>34.5%</td>
<td>Yes</td>
</tr>
<tr>
<td>MI</td>
<td>52</td>
<td>22</td>
<td>42.3%</td>
<td>Yes</td>
</tr>
<tr>
<td>NC</td>
<td>52</td>
<td>35</td>
<td>67.3%</td>
<td>Yes</td>
</tr>
<tr>
<td>NJ</td>
<td>52</td>
<td>28</td>
<td>53.8%</td>
<td>Yes</td>
</tr>
<tr>
<td>MA</td>
<td>51</td>
<td>33</td>
<td>64.7%</td>
<td>Yes</td>
</tr>
<tr>
<td>TN</td>
<td>48</td>
<td>20</td>
<td>41.7%</td>
<td>Yes</td>
</tr>
<tr>
<td>WA</td>
<td>44</td>
<td>19</td>
<td>43.2%</td>
<td>Yes</td>
</tr>
<tr>
<td>GA</td>
<td>39</td>
<td>17</td>
<td>43.6%</td>
<td>Yes</td>
</tr>
<tr>
<td>MO</td>
<td>39</td>
<td>16</td>
<td>41.0%</td>
<td>Yes</td>
</tr>
<tr>
<td>VA</td>
<td>39</td>
<td>27</td>
<td>69.2%</td>
<td>Yes</td>
</tr>
<tr>
<td>IN</td>
<td>37</td>
<td>13</td>
<td>35.1%</td>
<td>Yes</td>
</tr>
<tr>
<td>AL</td>
<td>35</td>
<td>12</td>
<td>34.3%</td>
<td>Yes</td>
</tr>
<tr>
<td>SC</td>
<td>31</td>
<td>11</td>
<td>35.5%</td>
<td>Yes</td>
</tr>
<tr>
<td>MD</td>
<td>29</td>
<td>14</td>
<td>48.3%</td>
<td>Yes</td>
</tr>
<tr>
<td>KY</td>
<td>28</td>
<td>10</td>
<td>35.7%</td>
<td>Yes</td>
</tr>
<tr>
<td>OK</td>
<td>28</td>
<td>10</td>
<td>35.7%</td>
<td>Yes</td>
</tr>
<tr>
<td>LA</td>
<td>26</td>
<td>6</td>
<td>23.1%</td>
<td>Yes</td>
</tr>
<tr>
<td>NE</td>
<td>25</td>
<td>4</td>
<td>16.0%</td>
<td>Yes</td>
</tr>
<tr>
<td>OR</td>
<td>25</td>
<td>9</td>
<td>36.0%</td>
<td>Yes</td>
</tr>
<tr>
<td>CO</td>
<td>24</td>
<td>14</td>
<td>58.3%</td>
<td>Yes</td>
</tr>
<tr>
<td>NV</td>
<td>21</td>
<td>8</td>
<td>38.1%</td>
<td>Yes</td>
</tr>
<tr>
<td>WI</td>
<td>20</td>
<td>12</td>
<td>60.0%</td>
<td>Yes</td>
</tr>
<tr>
<td>AR</td>
<td>19</td>
<td>3</td>
<td>15.8%</td>
<td>Yes</td>
</tr>
<tr>
<td>KS</td>
<td>18</td>
<td>4</td>
<td>22.2%</td>
<td>Yes</td>
</tr>
<tr>
<td>CT</td>
<td>17</td>
<td>14</td>
<td>82.4%</td>
<td>Yes</td>
</tr>
<tr>
<td>IA</td>
<td>15</td>
<td>7</td>
<td>46.7%</td>
<td>Yes</td>
</tr>
<tr>
<td>SD</td>
<td>14</td>
<td>3</td>
<td>21.4%</td>
<td>Yes</td>
</tr>
<tr>
<td>MN</td>
<td>13</td>
<td>11</td>
<td>84.6%</td>
<td>Yes</td>
</tr>
<tr>
<td>MS</td>
<td>11</td>
<td>3</td>
<td>27.3%</td>
<td>Yes</td>
</tr>
<tr>
<td>NM</td>
<td>10</td>
<td>5</td>
<td>50.0%</td>
<td>Yes</td>
</tr>
<tr>
<td>UT</td>
<td>10</td>
<td>3</td>
<td>30.0%</td>
<td>Yes</td>
</tr>
<tr>
<td>ME</td>
<td>9</td>
<td>6</td>
<td>66.7%</td>
<td>Yes</td>
</tr>
<tr>
<td>NH</td>
<td>9</td>
<td>5</td>
<td>55.6%</td>
<td>Yes</td>
</tr>
<tr>
<td>WV</td>
<td>8</td>
<td>3</td>
<td>37.5%</td>
<td>Yes</td>
</tr>
<tr>
<td>RI</td>
<td>7</td>
<td>5</td>
<td>71.4%</td>
<td>Yes</td>
</tr>
<tr>
<td>DC</td>
<td>6</td>
<td>5</td>
<td>83.3%</td>
<td>Yes</td>
</tr>
<tr>
<td>DE</td>
<td>6</td>
<td>4</td>
<td>66.7%</td>
<td>Yes</td>
</tr>
<tr>
<td>MT</td>
<td>6</td>
<td>2</td>
<td>33.3%</td>
<td>Yes</td>
</tr>
<tr>
<td>ID</td>
<td>5</td>
<td>3</td>
<td>60.0%</td>
<td>Yes</td>
</tr>
<tr>
<td>ND</td>
<td>5</td>
<td>0</td>
<td>0.0%</td>
<td>No</td>
</tr>
<tr>
<td>HI</td>
<td>3</td>
<td>3</td>
<td>100.0%</td>
<td>Yes</td>
</tr>
<tr>
<td>VT</td>
<td>3</td>
<td>2</td>
<td>66.7%</td>
<td>Yes</td>
</tr>
<tr>
<td>PR</td>
<td>2</td>
<td>0</td>
<td>0.0%</td>
<td>No</td>
</tr>
<tr>
<td>AK</td>
<td>1</td>
<td>0</td>
<td>0.0%</td>
<td>No</td>
</tr>
<tr>
<td>WY</td>
<td>1</td>
<td>0</td>
<td>0.0%</td>
<td>No</td>
</tr>
</tbody>
</table>

**Supplementary Table S8.** Suppression sensitivity. Hypothetical
suppressed low-volume providers (25% and 50% of the observed count, each
performing 1–10 services) were added to each group before recomputing
the Gini coefficient and HHI. Concentration rose only modestly, so the
low-concentration conclusion is robust to the unobserved low-volume
tail.

<table>
<colgroup>
<col style="width: 19%" />
<col style="width: 12%" />
<col style="width: 18%" />
<col style="width: 18%" />
<col style="width: 11%" />
<col style="width: 17%" />
</colgroup>
<thead>
<tr>
<th>Specialty</th>
<th>Observed Gini</th>
<th>Gini +25% suppressed</th>
<th>Gini +50% suppressed</th>
<th>Observed HHI</th>
<th>HHI +50% suppressed</th>
</tr>
</thead>
<tbody>
<tr>
<td>URPS (OB/GYN)</td>
<td>0.51</td>
<td>0.59</td>
<td>0.64</td>
<td>33</td>
<td>31</td>
</tr>
<tr>
<td>URPS (urology)</td>
<td>0.53</td>
<td>0.60</td>
<td>0.65</td>
<td>149</td>
<td>140</td>
</tr>
<tr>
<td>Urology (non-URPS)</td>
<td>0.52</td>
<td>0.59</td>
<td>0.62</td>
<td>65</td>
<td>59</td>
</tr>
<tr>
<td>Other non-URPS OB/GYN</td>
<td>0.56</td>
<td>0.62</td>
<td>0.65</td>
<td>89</td>
<td>81</td>
</tr>
</tbody>
</table>

**Supplementary Table S9.** Annual observable participation transitions
using a two-year washout. Newly observable surgeons were absent in both
prior observable years; surgeons no longer observable were absent in
both subsequent observable years. Newly observable and continuing counts
are undefined for the first two years, and no-longer-observable counts
are undefined for the last two years. These describe threshold
crossings, not definitive entry into or exit from practice.

<table style="width:100%;">
<colgroup>
<col style="width: 6%" />
<col style="width: 12%" />
<col style="width: 10%" />
<col style="width: 12%" />
<col style="width: 9%" />
<col style="width: 23%" />
<col style="width: 24%" />
</colgroup>
<thead>
<tr>
<th>Year</th>
<th>Observable</th>
<th>Entrants</th>
<th>Continuing</th>
<th>Exiting</th>
<th>% volume by entrants</th>
<th>Median entrant volume</th>
</tr>
</thead>
<tbody>
<tr>
<td>2013</td>
<td>779</td>
<td>n/a</td>
<td>n/a</td>
<td>204</td>
<td>n/a</td>
<td>n/a</td>
</tr>
<tr>
<td>2014</td>
<td>656</td>
<td>n/a</td>
<td>n/a</td>
<td>156</td>
<td>n/a</td>
<td>n/a</td>
</tr>
<tr>
<td>2015</td>
<td>627</td>
<td>120</td>
<td>507</td>
<td>123</td>
<td>13.8%</td>
<td>13</td>
</tr>
<tr>
<td>2016</td>
<td>665</td>
<td>143</td>
<td>522</td>
<td>118</td>
<td>14.5%</td>
<td>13</td>
</tr>
<tr>
<td>2017</td>
<td>694</td>
<td>135</td>
<td>559</td>
<td>189</td>
<td>13.0%</td>
<td>13</td>
</tr>
<tr>
<td>2018</td>
<td>640</td>
<td>130</td>
<td>510</td>
<td>146</td>
<td>13.8%</td>
<td>14</td>
</tr>
<tr>
<td>2019</td>
<td>610</td>
<td>111</td>
<td>499</td>
<td>212</td>
<td>11.7%</td>
<td>13</td>
</tr>
<tr>
<td>2020</td>
<td>423</td>
<td>46</td>
<td>377</td>
<td>64</td>
<td>7.4%</td>
<td>13</td>
</tr>
<tr>
<td>2021</td>
<td>429</td>
<td>72</td>
<td>357</td>
<td>75</td>
<td>12.1%</td>
<td>13</td>
</tr>
<tr>
<td>2022</td>
<td>524</td>
<td>150</td>
<td>374</td>
<td>n/a</td>
<td>21.7%</td>
<td>14</td>
</tr>
<tr>
<td>2023</td>
<td>522</td>
<td>112</td>
<td>410</td>
<td>n/a</td>
<td>14.9%</td>
<td>13</td>
</tr>
</tbody>
</table>

Newly observable episodes by specialty: URPS, 480; urology, 165; other
OB/GYN, 205; MIGS, 8.

**Supplementary Table S11.** Classification sensitivity for ambiguous
and facility billers (reviewer concern). The primary analysis excludes
facility NPIs and places remaining non-physician or unclassifiable
clinicians in an “Other/uncertain” group. Assigning them to urology (the
legacy approach) roughly doubles the apparent non-URPS urology share;
excluding them entirely changes the shares little for the well-populated
groups. The URPS increase is significant under all three.

<table style="width:100%;">
<colgroup>
<col style="width: 57%" />
<col style="width: 10%" />
<col style="width: 10%" />
<col style="width: 21%" />
</colgroup>
<thead>
<tr>
<th>Handling of ambiguous billers</th>
<th>Physicians</th>
<th>URPS share</th>
<th>Non-URPS urology share</th>
</tr>
</thead>
<tbody>
<tr>
<td>Separate ‘Other/uncertain’ group; facilities excluded (primary)</td>
<td>1,666</td>
<td>63.7%</td>
<td>14.5%</td>
</tr>
<tr>
<td>Excluded from the cohort</td>
<td>1,467</td>
<td>69.3%</td>
<td>15.8%</td>
</tr>
<tr>
<td>Assigned to urology (legacy)</td>
<td>1,789</td>
<td>60.8%</td>
<td>26.1%</td>
</tr>
</tbody>
</table>

------------------------------------------------------------------------

## Supplementary Figures

<img
src="/Users/tylermuffly/sling-volume-patterns/output/figures/figure_2_volume_distribution.png"
style="width:6.5in" />

**Supplementary Figure S1.** Annual sling service volume (CPT 57288) by
specialty (violin and box plots; logarithmic scale). The minimum
observable volume is 11 because of CMS cell suppression.

<img
src="/Users/tylermuffly/sling-volume-patterns/output/figures/figure_3_lorenz_curve.png"
style="width:6.5in" />

**Supplementary Figure S2.** Lorenz curves of procedural concentration
by specialty. Greater distance from the diagonal indicates greater
concentration.

<img
src="/Users/tylermuffly/sling-volume-patterns/output/figures/figure_4_concentration_trends.png"
style="width:6.5in" />

**Supplementary Figure S3.** Annual within-year concentration by
specialty (Gini, HHI, top-20% share, bottom-50% share). Within-year
concentration was low and stable. MIGS was excluded because too few
surgeons were observed each year for stable estimates.

<img
src="/Users/tylermuffly/sling-volume-patterns/output/figures/figure_5_supply_trends.png"
style="width:6.5in" />

**Supplementary Figure S4.** Observable surgeons and total reported
services by year and specialty. The decline in the observable surgeon
pool was concentrated in urology and General OB/GYN.
