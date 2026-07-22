> **Revision note (analysis update).** This version incorporates five
> changes: (1) URPS includes both certification pathways, ABOG (OB/GYN)
> and ABU (urology); (2) all 11 calendar years are analyzed, after the
> 2017 file (initially a truncated download) was replaced with the
> complete release; (3) surgeon-level concentration is reported with
> both the Gini coefficient and Herfindahl–Hirschman Index (HHI); (4)
> annual volume is analyzed with a repeated-measures model; and (5)
> specialty-classification assumptions are examined in sensitivity
> analyses. These updates changed several estimates from the original
> submission.

## Abstract

**Objective:** To describe the specialty distribution, annual surgeon
volume, and procedural concentration of physicians performing
midurethral sling surgery (CPT 57288) for Medicare beneficiaries.

**Methods:** We analyzed the CMS Medicare Physician and Other
Practitioners Public Use File across all 11 calendar years, 2013 through
2023. Physicians billing CPT 57288 were classified as Urogynecology and
Reconstructive Pelvic Surgery (URPS), Minimally Invasive Gynecologic
Surgery (MIGS), General OB/GYN, or non-URPS urology by combining CMS
provider type with ABOG and ABU subspecialty rosters. We measured
surgeon-level concentration with the Gini coefficient and HHI, both
overall and by year. Annual volume was modeled with a Poisson
generalized estimating equation clustered by NPI; a per-physician
Kruskal-Wallis analysis was secondary. Market-share trends were
evaluated under fixed-membership and certification-gated classifications
designed to bound the likely trend, with modal and ever-URPS/MIGS
sensitivity analyses.

**Results:** Across 2013 through 2023, 1,789 physicians performed
147,632 procedures across 6,937 physician-years. URPS was the largest
group (767 physicians; 89,773 procedures, 60.8%; median 19/year
\[p25–p75, 14–28\]), followed by non-URPS urology (689 physicians;
26.1%; median 16), General OB/GYN (336; 12.4%; median 15), and MIGS (10;
0.6%; median 16). Annual procedures declined from 16,399 in 2013 to
12,223 in 2023 (-490/year; p = 0.023), with a low of 9,228 in 2020 and
partial recovery thereafter. Compared with URPS, adjusted annual volume
was lower for urology (rate ratio \[RR\] 0.80 (0.70–0.92)), General
OB/GYN (RR 0.68 (0.51–0.92)), and MIGS (RR 0.56 (0.40–0.79)). Volume
fell by approximately 11% in 2020 (RR 0.88 (0.85–0.92); p &lt; 0.001),
but per-physician volume did not change overall (RR 1.00 (0.99–1.01); p
= 0.516). Among the three well-populated groups, pooled concentration
was modest and lowest for URPS (Gini 0.52, HHI 27; top 20% performed
53.9%); within-year concentration remained low and stable (annual Gini
approximately 0.26–0.28; p for trend = 0.733). URPS share increased by
0.90 percentage points per year (p &lt; 0.001), whereas urology (-0.55;
p = 0.002) and General OB/GYN (-0.41; p = 0.004) declined. The increase
remained significant under every classification scheme, and the two
schemes bracketed the rate of increase rather than the level. Under
fixed membership URPS rose from 53.4% to 63.8% (+0.90 percentage
points/year); under certification-gated classification it rose more
steeply, from 42.2% to 62.8% (+1.52 percentage points/year), because
pre-certification physicians count as generalists, and the two estimates
converged by 2023. Newly observable surgeons performed 7.4%–22.5% of
annual volume at a median of approximately 13 cases; URPS contributed
the most entrants (480), while urology showed substantial turnover (421
entrants despite a declining share).

**Conclusions:** URPS physicians perform most midurethral sling
procedures in fee-for-service Medicare and have the highest adjusted
per-physician volume and the most even within-group distribution. The
rising gynecologic share reflects attrition among non-URPS providers
rather than increasing surgeon-level concentration, with implications
for credentialing and workforce planning.

------------------------------------------------------------------------

## Introduction

Midurethral sling surgery is the most common operation for stress
urinary incontinence (SUI) and remains the standard surgical treatment
when conservative care fails.<sup>1,2</sup> The procedure, coded as CPT
57288, places a synthetic mesh sling beneath the midurethra. Despite its
widespread use, little is known about which specialties perform these
procedures in the Medicare population or how volume is distributed among
surgeons.

These questions matter for surgical quality, training, and workforce
planning. Across surgery, higher surgeon and hospital volume is
generally associated with better outcomes.<sup>4,5</sup> Evidence for
procedure-specific volume thresholds in midurethral sling surgery is
more limited. The specialty mix has also changed during the past decade.

Three developments make this analysis timely. First, Female Pelvic
Medicine and Reconstructive Surgery, now named Urogynecology and
Reconstructive Pelvic Surgery (URPS), has grown since receiving American
Board of Medical Specialties recognition in 2013.<sup>6</sup>
Certification is available through both obstetrics and gynecology (ABOG)
and urology (ABU) pathways. Second, US Food and Drug Administration
actions on urogynecologic mesh, including the 2019 order ending sales of
transvaginal mesh for prolapse, changed public perception and may have
affected sling use.<sup>7</sup> Third, procedural concentration, the
extent to which a relatively small group of clinicians performs a large
share of procedures, has become relevant to quality improvement and
resource allocation.<sup>8</sup>

We therefore characterized specialty distribution, annual surgeon
volume, and procedural concentration among physicians performing
midurethral sling surgery for Medicare beneficiaries from 2013 through
2023. We also evaluated changes in each specialty’s share of procedures
over time.

## Methods

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

The 2017 file initially obtained was an incomplete download (roughly
half the expected size, with only 376 sling provider-year records versus
approximately 660–810 in neighboring years). It was replaced with the
complete 2017 release before analysis, so all 11 calendar years are
included.

### Specialty Classification

Providers were assigned to four mutually exclusive groups: URPS, MIGS,
General OB/GYN, or non-URPS urology. We first used the annual CMS
provider type (Rndrng\_Prvdr\_Type), which may vary by year, to identify
OB/GYN, urology, or another specialty. Providers billing CPT 57288 who
had neither an OB/GYN nor urology CMS type and were not in the ABOG
registry were reclassified as urology. Among OB/GYN physicians, the ABOG
subspecialty registry identified “Female Pelvic Medicine and
Reconstructive Surgery” as URPS and “MIG” as MIGS; all other OB/GYN
physicians were classified as General OB/GYN.

We then cross-referenced the American Board of Urology roster to
identify urology-pathway urogynecologists. These physicians were
combined with ABOG-certified urogynecologists in a single URPS group;
all remaining urologists were classified as non-URPS urology. Without
this step, fellowship-trained urology-pathway urogynecologists would
appear only as “Urology” in the PUF. We excluded other surgical provider
types because they were too heterogeneous to interpret.

Specialty assignment could affect the estimated market-share trend
because 45% of URPS physicians in the cohort were certified after 2013.
We therefore used two primary classification schemes to bound the likely
change. Fixed-membership classification assigns each physician’s
eventual subspecialty to every study year. Because this approach counts
physicians as URPS before certification, it provides a lower bound on
the rate of increase.

Time-varying, certification-gated classification counts a physician as
URPS or MIGS only beginning in the ABOG subspecialty certification year
(sub1startdate, 2013–2024, distinct from the initial OB/GYN board date).
Earlier years are classified by that year’s CMS provider type. Because
certification generally follows the start of subspecialty practice (the
2013 examination certified physicians already practicing urogynecology,
and later diplomates also practiced before certification), this approach
misclassifies some pre-certification practice years and provides an
upper bound.

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
not observed, so the true number of low-volume surgeons is unknown and
the reported concentration estimates are lower bounds.

### Outcome Measures and Statistical Analysis

The primary outcome was the annual number of midurethral sling
procedures per provider. We measured surgeon-level concentration with
two complementary metrics. The Gini coefficient summarizes inequality
across the full surgeon-volume distribution. The Herfindahl–Hirschman
Index (HHI) sums squared surgeon shares on a 0–10,000 scale and is more
sensitive to the largest-volume surgeons. Both measures were calculated
from aggregate provider totals and separately for each calendar year.

The physician was the operative production unit in these calculations.
Thus, HHI describes surgeon-level procedural concentration rather than
hospital or health-system market competition and should not be
interpreted using FTC/DOJ antitrust thresholds.

Because each physician contributed as many as ten annual observations,
physician-year records were correlated. We modeled annual procedure
count with a Poisson generalized estimating equation clustered by NPI,
using an exchangeable working correlation and robust standard errors.
Fixed effects included specialty (URPS reference), calendar year,
specialty-by-year interaction, and a 2020 COVID indicator. We report
adjusted rate ratios with 95% CIs. A negative-binomial mixed model with
a random intercept for NPI produced concordant estimates.

As a secondary analysis with one independent observation per physician,
we compared each physician’s median annual volume across specialties
using the Kruskal-Wallis test and Bonferroni-adjusted pairwise Wilcoxon
tests.

To estimate market-share trends, we separately regressed each
specialty’s annual percentage share on calendar year using ordinary
least squares. We modeled URPS, urology, General OB/GYN, and the
combined gynecologic share; MIGS was described without formal emphasis
because only 10 physicians were identified.

To describe workforce turnover, we used a two-year washout. A surgeon
was classified as an entrant when observable in a given year but absent
in both prior observable years; as continuing when observable and not an
entrant; and as apparently exiting when absent in both subsequent
observable years. We calculated entrant share of annual volume, median
entrant volume, and entrants by specialty. Because CMS suppression
removes providers below 11 beneficiaries, we use the term newly
observable rather than definitively new sling surgeon.

In a secondary geographic analysis, we tabulated observable surgeons and
URPS share by practice state and identified states with no observable
URPS surgeon performing at least 11 Medicare slings in any study year.
We did not calculate population-based rates because fee-for-service
denominators adjusted for Medicare Advantage enrollment were outside the
scope of this analysis.

Analyses were performed in R 4.4, with package versions locked through
renv. The complete analytic pipeline is available at
<https://github.com/mufflyt/sling-volume-patterns>.

## Results

### Cohort and Annual Volume

Across the full 11-year window, 1,789 physicians billed CPT 57288,
accounting for 147,632 observed services in 6,937 physician-year
observations. Participation was intermittent: 560 physicians (31%)
appeared in one year, 756 (42%) in 2–5 years, 365 (20%) in 6–10 years,
and 108 (6%) in all 11 years. Thus, only a small proportion maintained
an observable Medicare sling practice throughout the study window.

Observed annual volume declined from 16,399 procedures in 2013 to 12,223
in 2023 (linear trend, -490 procedures/year; p = 0.023). The number of
observable surgeons also fell, from 812 to 562. Volume reached a low of
9,228 procedures in 2020, consistent with pandemic-related deferral of
elective surgery. It partially recovered to 12,053 in 2022 and 12,223 in
2023 but remained below pre-2020 levels. Therefore, the pooled total
masks a decade-long decline in Medicare sling volume.

### Specialty Distribution and Trends

URPS was the largest group: 767 physicians contributed 3,913
physician-years and 89,773 procedures (60.8%), with a median annual
volume of 19 (p25–p75, 14–28). Non-URPS urology included 689 physicians,
2,032 physician-years, and 38,602 procedures (26.1%; median 16, 13–22).
General OB/GYN included 336 physicians, 953 physician-years, and 18,316
procedures (12.4%; median 15, 12–22). MIGS included 10 physicians, 39
physician-years, and 941 procedures (0.6%; median 16, 12–24) (Table 1).

Because 13 physicians changed specialty groups across years,
specialty-specific physician counts exceed the unique cohort total.
Including urology-pathway urogynecologists reassigned 151 physicians and
12,272 procedures from urology to URPS compared with an ABOG-only
classification.

Annual market shares moved in different directions (Table 1). URPS
increased from 53.4% in 2013 to 63.8% in 2023 (+0.90 percentage
points/year; 95% CI 0.51 to 1.28; p &lt; 0.001). Urology decreased from
30.7% to 23.1% (-0.55 percentage points/year; 95% CI -0.84 to -0.26; p =
0.002), and General OB/GYN decreased from 15.7% to 12.3% (-0.41
percentage points/year; 95% CI -0.66 to -0.17; p = 0.004). MIGS
increased descriptively from 0.2% to 0.8% (+0.07 percentage
points/year), but this estimate is based on only 10 physicians. Because
total volume declined, these changes represent redistribution among
specialties rather than procedure growth.

The URPS increase was significant under every classification scheme, and
the schemes bracketed its slope (Table 4). Fixed membership gave the
shallower estimate because it counts physicians as URPS before
certification: URPS share rose from 53.4% to 63.8% (+0.90 percentage
points/year), and the gynecologic share from 60.8% to 70.1% (+0.85
percentage points/year). Certification-gated classification gave the
steeper estimate, from 42.2% to 62.8% (+1.52 percentage points/year),
because it removes not-yet-certified physicians from the early URPS
count; the two estimates converged near 62.8% by 2023.

In the Poisson GEE clustered by NPI, adjusted annual volume was lower
than URPS for every other group: urology RR 0.80 (0.70–0.92), General
OB/GYN RR 0.68 (0.51–0.92), and MIGS RR 0.56 (0.40–0.79) (Table 3).
Annual volume was approximately 11% lower in 2020 (RR 0.88 (0.85–0.92);
p &lt; 0.001). There was no overall change in per-physician volume over
time (year RR 1.00 (0.99–1.01); p = 0.516). The
one-observation-per-physician secondary analysis was concordant
(Kruskal-Wallis H = 66.6, df = 3, p &lt; 0.001); URPS volume exceeded
both urology and General OB/GYN in pairwise comparisons (p &lt; 0.001).

### Surgeon Volume and Concentration

Among the three well-populated groups, pooled multi-year concentration
was lowest for URPS (Gini 0.52, HHI 27; top 10% performed 34.4% and top
20% performed 53.9%). Concentration was slightly higher for urology
(Gini 0.53, HHI 35; top 20% performed 58.7%) and General OB/GYN (Gini
0.56, HHI 89; top 20% performed 62.2%) (Table 2).

The Gini coefficient and HHI ranked the groups identically. However, the
absolute HHI values for all three groups were very low (27–89 of
10,000), indicating that sling volume was unevenly distributed across
many surgeons rather than dominated by a few. URPS also had the highest
median annual volume and upper quartile (median 19; p75 28).

Within-year concentration was low and stable. The pooled annual Gini
ranged from 0.26 to 0.28, with no temporal trend (p = 0.733), and the
annual top 20% performed approximately 38% of cases. No
specialty-specific annual Gini changed significantly (all p &gt; 0.15).
Thus, care did not become concentrated among a smaller group of
high-volume surgeons as the observable surgeon pool contracted. MIGS was
excluded from these comparisons because only 10 physicians were
identified (1–4 per year); its nominal Gini of 0.61 and HHI of 3,036 are
not stable specialty-wide estimates.

### Workforce Entry and Exit

Using the two-year washout (Table 5), 48–168 surgeons were newly
observable each year and performed 7.4%–22.5% of annual volume. Their
median annual volume was low, at approximately 13 procedures, consistent
with surgeons appearing just above the CMS suppression threshold. Entry
fell to 48 surgeons and 7.4% of volume in 2020, then rebounded to 168
surgeons and 22.5% of volume in 2022. Continuing surgeons (381–584 per
year) performed most annual procedures, while apparent exits ranged from
66 to 230 per year.

Across the study period, URPS contributed the most entrants (480),
followed by urology (421), General OB/GYN (205), and MIGS (8). The
rising URPS share reflected the largest inflow of newly observable
surgeons together with a relatively stable continuing-URPS base (URPS
surgeon count 385 to 338; per-physician volume unchanged). Urology
showed substantial turnover but net attrition, and General OB/GYN lost
both surgeons and market share.

Because total volume declined, the gynecologic gain represents a
redistribution of a shrinking procedure pool toward URPS, not new
procedure growth. All turnover counts describe newly observable rather
than definitively new surgeons because low-volume providers are
suppressed.

### Geographic Distribution (Secondary)

Practice locations spanned 52 states and territories. The URPS share of
observable sling surgeons varied from 100% in Hawaii and 82%–85% in
Minnesota, the District of Columbia, and Connecticut to 15% in Nebraska.
Alaska, North Dakota, Puerto Rico, and Wyoming had no observable URPS
surgeon performing at least 11 Medicare slings in any study year.
Because of CMS suppression, this finding indicates no observable
higher-volume URPS surgeon, not necessarily no URPS physician.
Population-based rates and formal geographic inequality measures were
reserved for a separate access-focused analysis.

## Discussion

This national Medicare analysis produced three main findings. First,
URPS physicians performed most midurethral sling procedures (60.8%) and
had the highest adjusted per-physician volume. Second, the gynecologic
share increased over the decade as URPS surgeons entered the observable
workforce and non-URPS surgeons left. Third, surgeon-level concentration
remained low and stable despite a shrinking surgeon pool. Together,
these findings indicate a change in workforce composition rather than
intensification of individual practice or concentration of care.

### Specialty Distribution and the Historical Reversal

URPS physicians performed approximately three-fifths of Medicare slings,
and gynecologists collectively performed the majority. This finding is
consistent with contemporary practice-pattern data but reverses earlier
Medicare-specific patterns. In ACS-NSQIP data from 2006 through 2013,
James et al. reported that gynecologists performed 74.2% of sling
procedures and urologists performed 25.8%.<sup>9</sup> Cantrell et
al. found that urogynecologists performed 54% of stress-incontinence
procedures at academic centers from 2009 through 2014.<sup>10</sup> In
Medicare data from 2002 through 2007, however, Rogo-Gupta et al. found
that urologists performed most sling operations.<sup>11</sup> Our
2013–2023 findings indicate that this historical pattern has reversed,
with URPS now the largest single specialty group.

Including both certification pathways was essential to this result.
Cross-referencing the ABU roster reassigned 151 urology-typed
physicians, representing 8.3% of all sling procedures, to URPS. The
concentration estimate was robust: the pooled URPS Gini changed only
from 0.52 to 0.52. A pathway-neutral definition also reflects
differences in operative case volume between urology- and
gynecology-based URPS fellowships<sup>14</sup> and variable FPMRS
exposure during urology residency.<sup>15</sup> Classifying
urology-pathway urogynecologists as general urologists would therefore
understate the true subspecialty share.

### Procedural Concentration and the Volume–Outcome Relationship

The Gini coefficient and HHI provide complementary views of
concentration, and both supported the same conclusion. Moderate
inequality across the full distribution (Gini 0.52–0.56) coexisted with
very low absolute HHI values (27–89 of 10,000). In other words, sling
volume was distributed unevenly across many surgeons but was not
dominated by a few. Because the physician was the production unit, these
values describe surgeon-level procedural concentration rather than
market competition.

These patterns matter because greater surgeon volume has been associated
with better outcomes after midurethral sling surgery. Berger et
al. reported a lower adjusted risk of reoperation for sling failure
among higher-volume surgeons.<sup>16</sup> A systematic review by
Cartier et al. found that low-volume surgeons had higher odds of mesh
revision and repeat incontinence procedures.<sup>17</sup> Brennand and
Quan observed lower revision odds above approximately 50 cases per
year,<sup>18</sup> and Holdø and Svenningsen found better objective cure
rates with greater surgeon experience and annual volume.<sup>19</sup>
The observed Medicare medians of 15–19 procedures per year fall below
these thresholds. However, the PUF omits commercially insured, Medicare
Advantage, and younger patients, so total practice volume is higher. In
addition, providers below the CMS suppression threshold are absent.

### Temporal Trends, Workforce Dynamics, and the Evolving SUI Landscape

The repeated-measures model and turnover analysis clarify why the
gynecologic share increased. Individual physician volume did not change
over time, but the number of non-URPS surgeons fell while the URPS pool
remained comparatively stable. URPS also contributed the largest inflow
of newly observable surgeons, whereas urology had substantial turnover
but a net decline. The market-share shift therefore reflects workforce
composition within a shrinking procedure pool, not increasing individual
volume or concentration.

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
not observed and concentration estimates are lower bounds. Second, the
PUF includes only fee-for-service Medicare Part B claims; younger
patients and those covered by Medicare Advantage, Medicaid, commercial
insurance, or no insurance are not represented.

Third, specialty classification depends on CMS provider type and the
ABOG/ABU rosters. Physicians who completed URPS fellowship but were not
board-certified may therefore be misclassified. Fourth, the market-share
trend is bounded rather than point-identified. Certification follows the
start of subspecialty practice, so the certification-gated approach
(upper bound) assigns some pre-certification practice years to General
OB/GYN or urology. Conversely, fixed membership (lower bound) assigns
physicians to URPS before they subspecialized. The true trend lies
between these estimates and would require unavailable
fellowship-completion dates for point identification.

Approximately 8% of URPS physicians could not be matched to a
certification year, and urology-pathway URPS classification remained
fixed because no urology subspecialty date was available; both features
narrow the certification-gated estimate. Fifth, Tot\_Srvcs may include
bilateral or modifier-inflated services.

### Strengths

Strengths include a national, complete sample of fee-for-service
Medicare claims; identification of urogynecologists through both
certification pathways; complementary surgeon-level concentration
measures calculated both overall and by year; a model that accounts for
repeated observations within physicians; and a fully reproducible
analytic pipeline.

## Conclusions

In this national Medicare cohort, URPS physicians performed most
midurethral slings, had the highest adjusted per-physician volume, and
had the most even within-group volume distribution. The growing
gynecologic share reflected attrition among non-URPS providers rather
than increasing surgeon-level concentration. These workforce shifts
should inform training requirements, credentialing standards, and access
planning for pelvic floor surgical care.

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
physicians billing CPT 57288, Medicare PUF 2013–2023 (combined URPS). Δ
share is the annual percentage-point change from ordinary least-squares
regression on calendar year. Specialty-specific physician counts exceed
1,789 because 13 physicians changed groups across years. \*MIGS
estimates are descriptive because only 10 physicians were identified.

<table>
<colgroup>
<col style="width: 12%" />
<col style="width: 12%" />
<col style="width: 10%" />
<col style="width: 8%" />
<col style="width: 6%" />
<col style="width: 13%" />
<col style="width: 7%" />
<col style="width: 7%" />
<col style="width: 15%" />
<col style="width: 5%" />
</colgroup>
<thead>
<tr>
<th>Specialty</th>
<th>Unique physicians</th>
<th>Physician-years</th>
<th>Procedures</th>
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
<td>URPS</td>
<td>767</td>
<td>3,913</td>
<td>89,773</td>
<td>60.8%</td>
<td>19 (14–28)</td>
<td>53.4%</td>
<td>63.8%</td>
<td>+0.90 (0.51 to 1.28)</td>
<td>&lt;0.001</td>
</tr>
<tr>
<td>Urology (non-URPS)</td>
<td>689</td>
<td>2,032</td>
<td>38,602</td>
<td>26.1%</td>
<td>16 (13–22)</td>
<td>30.7%</td>
<td>23.1%</td>
<td>-0.55 (-0.84 to -0.26)</td>
<td>0.002</td>
</tr>
<tr>
<td>General OB/GYN</td>
<td>336</td>
<td>953</td>
<td>18,316</td>
<td>12.4%</td>
<td>15 (12–22)</td>
<td>15.7%</td>
<td>12.3%</td>
<td>-0.41 (-0.66 to -0.17)</td>
<td>0.004</td>
</tr>
<tr>
<td>MIGS</td>
<td>10</td>
<td>39</td>
<td>941</td>
<td>0.6%</td>
<td>16 (12–24)</td>
<td>0.2%</td>
<td>0.8%</td>
<td>+0.07 (0.03 to 0.11)*</td>
<td>0.005</td>
</tr>
<tr>
<td><strong>Total</strong></td>
<td><strong>1,789</strong></td>
<td><strong>6,937</strong></td>
<td><strong>147,632</strong></td>
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
on aggregate provider volume.

<table>
<colgroup>
<col style="width: 24%" />
<col style="width: 15%" />
<col style="width: 7%" />
<col style="width: 19%" />
<col style="width: 16%" />
<col style="width: 16%" />
</colgroup>
<thead>
<tr>
<th>Specialty</th>
<th>N providers</th>
<th>Gini</th>
<th>HHI (0-10,000)</th>
<th>% by top 10%</th>
<th>% by top 20%</th>
</tr>
</thead>
<tbody>
<tr>
<td>URPS</td>
<td>767</td>
<td>0.52</td>
<td>27</td>
<td>34.4%</td>
<td>53.9%</td>
</tr>
<tr>
<td>Urology (non-URPS)</td>
<td>689</td>
<td>0.53</td>
<td>35</td>
<td>39.5%</td>
<td>58.7%</td>
</tr>
<tr>
<td>General OB/GYN</td>
<td>336</td>
<td>0.56</td>
<td>89</td>
<td>44.4%</td>
<td>62.2%</td>
</tr>
<tr>
<td>MIGS</td>
<td>10</td>
<td>0.61</td>
<td>3,036</td>
<td>49.8%</td>
<td>69.3%</td>
</tr>
</tbody>
</table>

**Table 3.** Adjusted rate ratios for annual sling volume from a Poisson
GEE clustered by NPI (URPS reference; exchangeable correlation; robust
standard errors).

<table>
<thead>
<tr>
<th>Term</th>
<th>Rate ratio (95% CI)</th>
<th>p-value</th>
</tr>
</thead>
<tbody>
<tr>
<td>Urology (vs URPS)</td>
<td>0.80 (0.70–0.92)</td>
<td>0.001</td>
</tr>
<tr>
<td>General OB/GYN (vs URPS)</td>
<td>0.68 (0.51–0.92)</td>
<td>0.011</td>
</tr>
<tr>
<td>MIGS (vs URPS)</td>
<td>0.56 (0.40–0.79)</td>
<td>&lt;0.001</td>
</tr>
<tr>
<td>Calendar year (per year)</td>
<td>1.00 (0.99–1.01)</td>
<td>0.516</td>
</tr>
<tr>
<td>2020 (COVID) indicator</td>
<td>0.88 (0.85–0.92)</td>
<td>&lt;0.001</td>
</tr>
</tbody>
</table>

**Table 4.** URPS and gynecologic market-share trends under alternative
classification schemes. The schemes bracket the rate of increase: fixed
membership gives the shallower slope because it counts physicians as
URPS before certification, and certification-gated classification gives
the steeper slope because it removes not-yet-certified physicians from
the early URPS count. The 2023 levels converge. All estimated trends are
positive and statistically significant.

<table>
<colgroup>
<col style="width: 58%" />
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
<td>Fixed membership: gynecologic share (ABOG-URPS + MIGS + Gen
OB/GYN)</td>
<td>60.8% → 70.1%</td>
<td>0.85</td>
<td>&lt;0.001</td>
</tr>
<tr>
<td>Fixed membership: combined-URPS share</td>
<td>53.4% → 63.8%</td>
<td>0.90</td>
<td>&lt;0.001</td>
</tr>
<tr>
<td>Modal: URPS share</td>
<td>n/a</td>
<td>0.97</td>
<td>&lt;0.001</td>
</tr>
<tr>
<td>Ever-URPS/MIGS: URPS share</td>
<td>n/a</td>
<td>0.95</td>
<td>0.001</td>
</tr>
<tr>
<td><strong>Certification-gated: URPS share (time-varying)</strong></td>
<td><strong>42.2% → 62.8%</strong></td>
<td><strong>1.52</strong></td>
<td><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td>Certification-gated: gynecologic share (time-varying)</td>
<td>n/a</td>
<td>0.54</td>
<td>&lt;0.001</td>
</tr>
</tbody>
</table>

**Table 5.** Annual sling workforce dynamics using a two-year washout.
Entrants were absent in both prior observable years; apparent exits were
absent in both subsequent observable years. Entrant and continuing
counts are undefined for the first two years, and exit counts are
undefined for the last two years.

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
<td>812</td>
<td>n/a</td>
<td>n/a</td>
<td>214</td>
<td>n/a</td>
<td>n/a</td>
</tr>
<tr>
<td>2014</td>
<td>685</td>
<td>n/a</td>
<td>n/a</td>
<td>164</td>
<td>n/a</td>
<td>n/a</td>
</tr>
<tr>
<td>2015</td>
<td>655</td>
<td>127</td>
<td>528</td>
<td>129</td>
<td>14.2%</td>
<td>13</td>
</tr>
<tr>
<td>2016</td>
<td>701</td>
<td>158</td>
<td>543</td>
<td>126</td>
<td>15.3%</td>
<td>13</td>
</tr>
<tr>
<td>2017</td>
<td>735</td>
<td>151</td>
<td>584</td>
<td>204</td>
<td>13.9%</td>
<td>14</td>
</tr>
<tr>
<td>2018</td>
<td>672</td>
<td>134</td>
<td>538</td>
<td>154</td>
<td>13.7%</td>
<td>14</td>
</tr>
<tr>
<td>2019</td>
<td>650</td>
<td>125</td>
<td>525</td>
<td>230</td>
<td>12.7%</td>
<td>13</td>
</tr>
<tr>
<td>2020</td>
<td>445</td>
<td>48</td>
<td>397</td>
<td>66</td>
<td>7.4%</td>
<td>13</td>
</tr>
<tr>
<td>2021</td>
<td>458</td>
<td>77</td>
<td>381</td>
<td>81</td>
<td>12.1%</td>
<td>13</td>
</tr>
<tr>
<td>2022</td>
<td>562</td>
<td>168</td>
<td>394</td>
<td>n/a</td>
<td>22.5%</td>
<td>14</td>
</tr>
<tr>
<td>2023</td>
<td>562</td>
<td>126</td>
<td>436</td>
<td>n/a</td>
<td>15.7%</td>
<td>13</td>
</tr>
</tbody>
</table>

Entrants by specialty: URPS, 480; urology, 421; General OB/GYN, 205;
MIGS, 8.

------------------------------------------------------------------------

## Figures

**Figure 1.** Market share of midurethral sling procedures (CPT 57288)
by specialty, Medicare PUF 2013–2023. The URPS share increased under
every classification scheme. Fixed membership (URPS share 53.4% to
63.8%; +0.90 percentage points/year) and certification-gated
classification (URPS share 42.2% to 62.8%; +1.52 percentage points/year)
bracket the rate of increase and converge by 2023.

**Figure 2.** Annual midurethral sling volume by specialty (violin and
box plots; logarithmic scale). The minimum observable volume is 11
because of CMS cell suppression.

**Figure 3.** Lorenz curves of procedural concentration by specialty.
Greater distance from the diagonal indicates greater concentration. URPS
(Gini 0.52) is closest to equality; MIGS (0.61) is farthest.

**Figure 4.** Annual concentration by specialty, measured by Gini, HHI,
top-20% share, and bottom-50% share. Within-year concentration was low
and stable. MIGS was excluded because too few surgeons were observed
each year for stable estimates.

**Figure 5.** Observable surgeons and total procedure volume by year and
specialty. The decline in the surgeon pool was concentrated in urology
and General OB/GYN.
