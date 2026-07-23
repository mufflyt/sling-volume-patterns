Specialty Distribution and Surgeon-Level Concentration of Sling Surgery
for Stress Urinary Incontinence in Fee-for-Service Medicare, 2013–2023
================
Tyler Muffly, MD

**Author:** Tyler Muffly, MD<sup>1</sup>

<sup>1</sup> *\[Affiliation to be completed: division, department,
institution, city, state\]*

**Corresponding author:** Tyler Muffly, MD. *\[mailing address,
telephone, and email to be completed\]*

**Funding:** *\[to be completed; state “None” if not applicable\]*

**Conflicts of interest:** *\[to be completed; state “The author reports
no conflicts of interest” if applicable\]*

**Acknowledgments:** *\[to be completed\]*

**Data and code availability:** The analytic code and non-restricted
derived outputs, together with this manuscript source, are available at
<https://github.com/mufflyt/sling-volume-patterns> *(repository to be
made public, with a tagged release, at acceptance)*. The CMS Medicare
Physician and Other Practitioners Public Use File and the CMS Program
Statistics Original Medicare Enrollment tables are publicly available
from data.cms.gov. The ABOG and ABU board-certification rosters used for
specialty linkage are subject to source-specific permissions and may not
be redistributable; provenance and derived crosswalk documentation are
provided in the repository.

**Manuscript type:** Original research.

------------------------------------------------------------------------

## Abstract

**Objectives:** To describe the specialty distribution, annual clinician
volume, and surgeon-level concentration of sling surgery for stress
urinary incontinence (CPT 57288) in fee-for-service Medicare from 2013
through 2023.

**Methods:** We analyzed all 11 annual CMS Medicare Physician and Other
Practitioners Public Use Files. Physicians billing CPT 57288 were
classified by annual CMS provider type and ABOG and ABU roster linkage
into all-pathway URPS (OB/GYN or urology certification), non-URPS
urology, other non-URPS OB/GYN, or MIGS; organizational and
unclassifiable billers were excluded from the primary cohort and
examined separately. The primary market-share estimand was the
all-pathway URPS share under fixed-membership classification. We modeled
utilization with female Part B fee-for-service enrollment as an offset,
annual volume with a Poisson generalized estimating equation clustered
by NPI, and URPS share with a quasibinomial model. Annual Gini
coefficients measured concentration.

**Results:** Among 1,467 physicians, 129,517 sling services were
observable. URPS physicians, identified through either certification
pathway, performed the majority (69.3%; OB/GYN pathway 59.8%, urology
pathway 9.5%); non-URPS urology performed 15.8% and other non-URPS
OB/GYN 14.2%. Reported services declined 30.7%; after enrollment
adjustment, the estimated utilization rate declined 2.4% per year (rate
ratio 0.976, 95% CI 0.955-0.997; p = 0.060). Under fixed-membership
classification, the all-pathway URPS share increased from 58.6% in 2013
to 75.4% in 2023 (+1.59 percentage points/year; p \< 0.001); the
increase remained significant under certification-gated classification.
OB/GYN-pathway URPS had the highest adjusted annual volume, and
within-year surgeon concentration remained stable.

**Conclusions:** In observable fee-for-service Medicare, URPS physicians
identified through either certification pathway performed most sling
services, and their share increased without a corresponding increase in
surgeon concentration. These findings describe claims-visible service
patterns, not the complete national surgical workforce; all-payer
outcome and access studies are needed before drawing credentialing
implications.

**Keywords:** stress urinary incontinence; sling surgery; urogynecology;
Medicare; surgical workforce.

------------------------------------------------------------------------

## Simply Stated

Sling surgery treats stress urinary incontinence, which causes urine
leakage with coughing, laughing, or exercise. We studied traditional
Medicare billing records from 2013 through 2023 to learn which doctors
performed these operations and how the work was shared. Urogynecologists
performed most of the reported surgeries, and their share increased over
time. The total number of reported surgeries fell. Some of that decline
occurred because fewer people were enrolled in traditional Medicare,
although a smaller true decline may remain. The work stayed spread
across many surgeons rather than becoming centered in a small group.
These data cannot show which specialty has the best outcomes or who
should be allowed to perform the operation.

## Why This Matters

National data on who performs sling surgery are limited. This study
improves classification by identifying urogynecologists through both the
obstetrics-gynecology and urology certification pathways, avoiding the
misclassification of urology-trained urogynecologists as general
urologists. It also pairs claims with fee-for-service enrollment,
showing that raw service counts overstate the decline in utilization.
The main finding is a growing URPS share without increasing within-year
surgeon concentration. These results support workforce surveillance, but
claims data alone cannot establish quality, access, or credentialing
standards.

------------------------------------------------------------------------

## Introduction

Sling surgery is a standard surgical treatment for stress urinary
incontinence (SUI) when conservative treatment is
insufficient.<sup>1,2</sup> CPT 57288 describes a “sling operation for
stress incontinence (eg, fascia or synthetic).” The code therefore
includes both autologous fascial and synthetic sling procedures and does
not distinguish sling material or retropubic, transobturator,
single-incision, and pubovaginal techniques. Despite the procedure’s
widespread use, little is known about which specialties perform it in
the Medicare population or how case volume is distributed among
surgeons.

These questions are relevant to surgical quality, training, and
workforce planning. Across surgical fields, greater surgeon and hospital
volume is generally associated with better outcomes,<sup>4,5</sup>
although procedure-specific volume thresholds for sling surgery remain
uncertain. Changes in the specialty mix may also affect training needs
and patient access.

Three developments make this analysis timely. First, Female Pelvic
Medicine and Reconstructive Surgery, approved as a subspecialty by the
American Board of Medical Specialties in 2011 with the first
certificates issued in 2013 and renamed Urogynecology and Reconstructive
Pelvic Surgery (URPS) in 2024, has expanded rapidly.<sup>6</sup>
Certification is available through both the American Board of Obstetrics
and Gynecology (ABOG) and the American Board of Urology (ABU). Second,
US Food and Drug Administration actions involving urogynecologic mesh
changed public perceptions and may have affected sling use.<sup>7</sup>
The 2019 order concerned transvaginal mesh for pelvic organ prolapse; it
did not remove synthetic midurethral slings for SUI from the market.
Third, the distribution of procedures across clinicians has become
increasingly relevant to quality improvement and resource
planning.<sup>8</sup>

We therefore examined specialty distribution, annual clinician volume,
and surgeon-level concentration among clinicians reporting CPT 57288
services in fee-for-service Medicare from 2013 through 2023. We also
evaluated changes in each specialty’s share of observable services.

## Materials and Methods

### Study Design and Data Source

We conducted a repeated cross-sectional analysis of the CMS Medicare
Physician and Other Practitioners Public Use File (PUF) from 2013
through 2023. The PUF contains publicly reportable fee-for-service
Medicare Part B claims aggregated to the provider-service level. Each
row represents a unique combination of National Provider Identifier
(NPI), Healthcare Common Procedure Coding System code, place of service,
and calendar year. Because the data are public and contain no protected
health information, institutional review board approval was not
required.

Before analysis, we verified all 11 annual PUF releases against the CMS
file specifications and confirmed that each expected year was complete.

### Specialty Classification

Each billing NPI was assigned to one of five analyzed physician groups
(URPS through the OB/GYN pathway, URPS through the urology pathway,
Minimally Invasive Gynecologic Surgery (MIGS), other non-URPS OB/GYN, or
non-URPS urology) or to a residual Other/uncertain category that we set
aside from the primary cohort. We first used the annual CMS
rendering-provider type, which may vary by year, to identify OB/GYN,
urology, and other clinicians. Among OB/GYN physicians, the ABOG
registry identified diplomates certified in Female Pelvic Medicine and
Reconstructive Surgery as URPS and those with a MIG designation as MIGS.
Records were linked primarily by exact NPI and, when necessary, by full
name and practice state. Remaining OB/GYN physicians were classified as
other non-URPS OB/GYN.

Among 323 NPIs with neither an OB/GYN nor urology CMS provider type and
no ABOG match, most represented organizations or nonphysician clinicians
rather than urologists, and none matched the ABU roster. We excluded 123
organizational NPIs (NPPES entity type 2, flagged by a
rendering-provider entity code of “O”) because they represented billing
entities, such as ambulatory surgery centers, hospitals, laboratories,
or groups, rather than individual clinicians. The remaining 200
individual nonphysician or unclassifiable billers (8.2% of observable
services) could not be confirmed as either specialty; we excluded them
from the primary physician cohort and retained them as a separate
Other/uncertain group only in sensitivity analyses. Figure 3 shows the
full classification flow. Supplementary Table S11 compares this primary
approach with retaining these billers as a separate group and with the
legacy approach of assigning them to urology; the legacy approach
approximately doubled the apparent non-URPS urology share.

We then cross-referenced the ABU roster of 355 urology-pathway
urogynecologists. Of these, 151 appeared in the analytic cohort and were
classified as urology-pathway URPS; all remaining urology physicians
were classified as non-URPS urology. Without this linkage,
fellowship-trained urology-pathway urogynecologists would appear as
general urologists in the PUF. We therefore report all-pathway URPS
separately from the OB/GYN-based share, because all-pathway URPS
includes urology-trained subspecialists who are not gynecologists.

Because 45% of URPS physicians in the cohort were certified after 2013,
the treatment of pre-certification years could affect the estimated
market-share trend. We therefore used two plausible scenarios with
opposing assumptions. Fixed membership assigned each physician’s
eventual subspecialty to every study year and therefore tended to
produce a shallower slope by counting physicians as URPS before
certification.

Certification-gated classification assigned URPS or MIGS status only
beginning in the ABOG subspecialty certification year (sub1startdate,
distinct from the initial OB/GYN board date). Earlier years were
classified using the annual CMS provider type. Because certification
generally follows the start of subspecialty practice, this scenario may
misclassify genuine pre-certification subspecialty practice and
therefore tends to produce a steeper slope. We treat the two approaches
as plausible scenarios rather than formal bounds.

Modal and ever-URPS/MIGS classifications were additional sensitivity
analyses. Urology-pathway URPS status remained fixed because the ABU
roster did not include a subspecialty certification date. For pooled
distribution, concentration, and volume analyses (Tables 1–3), each
physician was assigned to the eventual combined specialty group.

### CMS Data Suppression

CMS suppresses provider-service records when a clinician treats fewer
than 11 Medicare beneficiaries for a given code in a calendar year.
Every observable physician-year in this study therefore represents at
least 11 beneficiaries with CPT 57288. Clinicians below that threshold
are not visible, so the number and volume of low-volume surgeons cannot
be recovered from the PUF. Because suppression may affect the Gini
coefficient and HHI differently, full-market concentration is not
identified. We therefore report bootstrap confidence intervals and a
sensitivity analysis that adds hypothetical suppressed low-volume
providers before recalculating concentration.

### Outcome Measures and Statistical Analysis

The primary clinician-level outcome was annual reported CPT 57288
services per provider (Tot_Srvcs). To describe utilization, we
calculated observable services per 100,000 female Part B fee-for-service
beneficiaries using CMS Program Statistics Original Medicare enrollment
counts (table MDCR ENROLL AB 11, Sex = Female, Part B). We modeled
annual service counts with log female fee-for-service enrollment as an
offset and included a 2020 indicator. Because the PUF does not report
beneficiary age for the numerator, this rate is crude and not age
standardized.

We assessed surgeon-level concentration with complementary measures. The
Gini coefficient summarizes inequality across the surgeon-volume
distribution, and its 95% confidence interval was estimated by
bootstrapping providers. The Herfindahl–Hirschman Index (HHI) is more
sensitive to the largest-volume surgeons, but its minimum depends on the
number of providers. We therefore report raw HHI descriptively and also
present normalized HHI and the effective number of providers.
Within-year concentration was primary; pooled multi-year measures were
secondary because they also reflect the number of years each physician
remained observable. The physician, rather than the hospital or health
system, was the production unit, so these measures should not be
interpreted using antitrust thresholds.

Because physicians could contribute up to 11 annual observations, we
modeled annual reported services with a Poisson generalized estimating
equation clustered by NPI, using an exchangeable working correlation and
robust standard errors. The model was conditional on the physician-year
being observable above the CMS threshold. Fixed effects included
specialty (OB/GYN-pathway URPS reference), calendar year centered at
2018, specialty-by-year interactions, and a 2020 indicator. Specialty
main effects therefore represent adjusted rate ratios at 2018, and
specialty-specific annual trends were reported as marginal contrasts. A
negative-binomial mixed model with an NPI random intercept served as a
sensitivity analysis. We also repeated the analysis after excluding 2020
and after restricting the cohort to clinicians observable in at least
two years.

As a secondary analysis with one independent observation per physician,
we compared each physician’s median annual volume across specialties
using the Kruskal-Wallis test followed by Bonferroni-adjusted pairwise
Wilcoxon tests.

For the primary market-share analysis, we modeled OB/GYN-pathway URPS
services as a proportion of all annual observable services using a
quasibinomial generalized linear model with calendar year centered at
2018. We report the annual odds ratio and the marginal change in
percentage points per year. Separate ordinary least-squares regressions
of annual specialty shares are presented descriptively. MIGS was not
emphasized inferentially because only 10 physicians were identified.

To describe changes in observable participation, we used a two-year
washout. A surgeon was newly observable when present in a year but
absent from both preceding observable years, continuing when present and
not newly observable, and no longer observable when absent from both
subsequent observable years. We summarized their annual service share,
median volume, and specialty distribution. Because CMS suppression can
move clinicians above or below the reporting threshold, these categories
describe observation episodes rather than true entry into or exit from
clinical practice. A physician could contribute more than one newly
observable episode after an intervening gap.

In a secondary geographic analysis, we summarized observable surgeons
and URPS share by practice state and identified states with no
observable URPS surgeon performing at least 11 Medicare slings in any
study year. We did not calculate state-level population rates because
state-by-sex fee-for-service enrollment denominators were outside the
scope of this analysis.

Analyses were performed in R version 4.4, with package versions locked
through renv. The complete analytic pipeline is available at
<https://github.com/mufflyt/sling-volume-patterns>.

## Results

### Cohort and Annual Volume

Across the full 11-year window, 1,467 physicians billed CPT 57288,
accounting for 129,517 observed services in 6,056 physician-year
observations. Participation was intermittent: 414 physicians (28%)
appeared in one year, 621 (42%) in 2–5 years, 329 (22%) in 6–10 years,
and 103 (7%) in all 11 years. Thus, only a small proportion maintained
an observable Medicare sling practice throughout the study window.

The observed count of reported services fell from 14,939 in 2013 to
10,349 in 2023 (-30.7%). Over the same period the female Part B
fee-for-service population contracted from 18.35 million to 15.65
million beneficiaries (-14.7%). In a Poisson model of the annual service
count with log fee-for-service enrollment as an offset and a 2020
indicator, the observable utilization rate declined -2.4% per year (rate
ratio 0.976, 95% CI 0.955-0.997; about -21.7% over the decade), but with
only 11 annual observations and the pandemic interruption this trend was
not statistically robust (dispersion-adjusted p = 0.060). The rate
reached a low of 45.5 per 100,000 in 2020, consistent with
pandemic-related deferral of elective surgery, then partially recovered.
The number of observable surgeons also fell, from 742 to 466. A
clinically meaningful decline in observable utilization thus remains
possible, but the raw service-count drop overstates it because much of
that drop reflects the shrinking fee-for-service denominator; because
CMS suppresses low-volume physician-years, this is an
observable-services rate, not the total national fee-for-service rate.

### Specialty Distribution and Trends

URPS physicians, identified through either certification pathway,
performed the majority of observable services (69.3%; Table 1).
Separating the two pathways, OB/GYN-pathway URPS (ABOG-certified) was
the largest single group: 616 physicians, 77,501 services (59.8%),
median annual volume 19 (p25–p75, 14–29). Urology-pathway URPS (ABU
roster) added 151 physicians and 12,272 services (9.5%; median 16).
Non-URPS urology included 366 physicians and 20,475 services (15.8%;
median 15), other non-URPS OB/GYN 337 physicians and 18,328 services
(14.2%; median 15), and MIGS 10 physicians (0.7%; median 16).
Organizational and unclassifiable billers were excluded from this
primary physician cohort; including them changed the major specialty
shares only slightly (Supplementary Table S11).

Because 13 physicians changed specialty groups across years,
specialty-specific counts exceed the unique cohort total. The
urology-pathway URPS group (151 physicians, 12,272 services) would
otherwise be classified as general urology, understating the
subspecialty and overstating non-URPS urology.

Annual market shares moved in different directions (Table 1). URPS
increased from 48.6% in 2013 to 67.1% in 2023 (+1.86 percentage
points/year; 95% CI 1.44 to 2.28; p \< 0.001). Urology decreased from
23.9% to 9.2% (-1.32 percentage points/year; 95% CI -1.62 to -1.01; p \<
0.001), and General OB/GYN decreased from 17.4% to 14.5% (-0.36
percentage points/year; 95% CI -0.64 to -0.08; p = 0.017). MIGS
increased descriptively from 0.2% to 1% (+0.09 percentage points/year),
but this estimate is based on only 10 physicians. In the quasibinomial
model of URPS services out of all annual services, which respects the
compositional structure, the URPS share rose from a fitted 51.1% in 2013
to 69.8% in 2023 (odds ratio 1.083 (95% CI 1.067-1.098) per year; 1.89
percentage points per year; p \< 0.001), consistent with the descriptive
ordinary least-squares estimate. Because total service counts declined,
these changes represent redistribution among specialties rather than
growth in services.

The increase in all-pathway URPS share remained significant under every
classification scenario (Table 4). Fixed membership, which counts
physicians as URPS before certification, produced the shallower change
from 58.6% in 2013 to 75.4% in 2023 (+1.59 percentage points/year).
Certification-gated classification produced the steeper change from
46.3% to 74.2% (+2.26 percentage points/year). The estimates converged
by the end of the study period. These are prespecified scenarios
addressing uncertain pre-certification practice, not statistical
confidence bounds.

In the Poisson GEE clustered by NPI (reference = OB/GYN-pathway URPS;
calendar year centered at 2018), adjusted annual volume at mid-study was
lower than OB/GYN-pathway URPS for every other group, including
urology-pathway URPS (RR 0.75 (0.66–0.84)), non-URPS urology (RR 0.70
(0.58–0.84)), other non-URPS OB/GYN (RR 0.60 (0.38–0.94)), and MIGS (RR
0.78 (0.47–1.31)) (Table 3). Annual volume was approximately 12% lower
in 2020 (RR 0.87 (0.84–0.91); p \< 0.001). The specialty-by-year
interaction showed that per-physician volume was essentially flat over
time for the well-populated groups (OB/GYN-pathway URPS RR 0.999
(0.990-1.007), p = 0.794; urology-pathway URPS RR 0.988 (0.974-1.002), p
= 0.091; non-URPS urology RR 0.986 (0.968-1.004), p = 0.132; other
OB/GYN RR 0.996 (0.972-1.021), p = 0.764), increasing only for the
10-physician MIGS group (RR 1.086 (1.032-1.142); p = 0.002) (Table 3). A
negative-binomial mixed model with a random intercept per NPI reproduced
the direction but with attenuated magnitude (urology RR 0.78
(0.74–0.82), General OB/GYN RR 0.81 (0.77–0.85), 2020 RR 0.90
(0.87–0.93)); the attenuation is expected because the GEE estimates a
population-averaged (marginal) rate ratio whereas the mixed model
estimates a physician-conditional one. The one-observation-per-physician
secondary analysis agreed (Kruskal-Wallis H = 96.3, df = 4, p \< 0.001);
URPS volume exceeded urology and other OB/GYN in pairwise comparisons (p
\< 0.001), with no significant URPS-MIGS difference. Because these
models condition on the physician-year being observable above the CMS
reporting threshold, the estimand is annual service volume among
observable physician-years, not full-workforce practice volume; if
non-URPS physicians more often fall below the threshold, the URPS volume
advantage may be overstated.

### Surgeon Volume and Concentration

Within-year concentration was the primary concentration analysis. The
annual Gini coefficient remained stable, ranging from 0.26 to 0.28, with
no temporal trend (p = 0.648); the top 20% of observable surgeons
performed approximately 38% of annual services. No specialty-specific
annual Gini changed significantly. Thus, the contraction in the
observable surgeon pool was not accompanied by increasing concentration
among a smaller group of high-volume surgeons.

Pooled multi-year concentration was moderate: the Gini coefficient was
0.51 (95% CI 0.48-0.53) for OB/GYN-pathway URPS, 0.52 (95% CI 0.49-0.55)
for non-URPS urology, and 0.56 (95% CI 0.52-0.60) for other non-URPS
OB/GYN (Table 2). Bootstrap comparisons showed no difference between
URPS and urology (difference -0.016 (95% CI -0.050 to +0.021)), whereas
URPS was modestly less concentrated than other non-URPS OB/GYN (-0.056
(95% CI -0.097 to -0.010), confidence interval excluding zero).
Normalized HHI values were near zero. The effective provider count
represented 50% of OB/GYN-pathway URPS physicians, 42% of non-URPS
urologists, and 33% of other non-URPS OB/GYN physicians, indicating
broad distribution with somewhat greater inequality in the smaller
groups. A sensitivity analysis that added hypothetical suppressed
low-volume providers increased the Gini, particularly under the 50%
scenario (Supplementary Table S8); it therefore supports the narrow
conclusion that observable services were not dominated by a handful of
surgeons, but not a precise estimate of full-market concentration. MIGS
estimates were considered exploratory because only 10 physicians were
identified.

### Observable Participation Over Time

Using the two-year washout (Supplementary Table S9), 34–131 surgeons
became newly observable each year and performed 5.5%–20.2% of annual
volume. Their median volume was low, at approximately 13 services,
consistent with surgeons appearing just above the CMS suppression
threshold. Newly observable counts fell to 34 surgeons (5.5% of volume)
in 2020, then rebounded to 131 (20.2%) in 2022; the 2022 rebound may
partly reflect re-observation of surgeons who fell below the threshold
during the pandemic rather than genuinely new surgeons. Continuing
surgeons (329–522 per year) performed most annual services, while
surgeons no longer observable ranged from 56 to 192 per year.

Across the study period, URPS accounted for the most newly observable
episodes (480), followed by other non-URPS OB/GYN (205), non-URPS
urology (165), and MIGS (8); these are episode counts, not unique
physicians. The rising URPS share coincided with the largest inflow of
newly observable surgeons together with a relatively stable
continuing-URPS base (URPS surgeon count 304 to 293; per-physician
volume unchanged). Urology showed substantial turnover with net decline,
and General OB/GYN declined in both observable surgeons and market
share.

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

This analysis yielded three principal findings. First, URPS physicians,
identified through either certification pathway, performed the majority
of observable sling services (69.3%; OB/GYN pathway 59.8%, urology
pathway 9.5%), and OB/GYN-pathway URPS had the highest adjusted annual
volume. Second, under fixed-membership classification the all-pathway
URPS share increased substantially, from 58.6% to 75.4%, driven
primarily by the OB/GYN pathway, while non-URPS participation declined.
Third, within-year surgeon concentration remained stable despite a
smaller observable surgeon pool. These findings describe a shift in
claims-visible fee-for-service practice rather than increasing
individual volume or concentration. They should be interpreted as
practice patterns, not direct evidence of entry into or exit from the
clinical workforce.

### Specialty Distribution in Context

The two URPS pathways together performed 69.3% of observable
fee-for-service Medicare sling services: 59.8% through the OB/GYN
pathway and 9.5% through the urology pathway. Non-URPS urologists
performed 15.8%. Because all-pathway URPS includes urology-trained
subspecialists, it is not equivalent to a gynecologist share. The
estimated non-URPS urology share was sensitive to classification:
assigning facility and nonphysician billers to urology approximately
doubled it (Supplementary Table S11), illustrating how a simple
provider-type approach can inflate urology estimates. Comparisons with
earlier studies require caution because datasets, specialty definitions,
and care settings differed. James et al. reported that gynecologists
performed 74.2% of sling procedures in ACS-NSQIP data from 2006 through
2013;<sup>9</sup> Cantrell et al. found that urogynecologists performed
54% of stress-incontinence procedures at academic centers from 2009
through 2014;<sup>10</sup> and Rogo-Gupta et al. found that urologists
performed most Medicare sling operations from 2002 through
2007.<sup>11</sup> The most defensible contemporary conclusion is that
OB/GYN-pathway URPS was the largest single fee-for-service Medicare
group performing CPT 57288.

Including both certification pathways was essential. Linking the ABU
roster reclassified 151 urology-typed physicians, representing 9.5% of
all observable services, as urology-pathway URPS. This pathway-neutral
definition reflects differences in operative case volume between
urology- and gynecology-based URPS fellowships<sup>14</sup> and variable
URPS exposure during urology residency.<sup>15</sup> Classifying these
subspecialists as general urologists would understate the URPS share and
overstate non-URPS urology.

### Procedural Concentration and the Volume–Outcome Relationship

The concentration measures offered complementary information.
Within-year Gini coefficients were low and stable, while pooled
multi-year Gini coefficients showed moderate inequality because they
also reflected the number of years each surgeon remained observable.
URPS and non-URPS urology had similar pooled concentration, whereas
other non-URPS OB/GYN was modestly more concentrated. Normalized HHI
values remained near zero, and effective provider counts were large. In
practical terms, observable sling volume was spread across many surgeons
rather than dominated by a few. Because physicians were the production
unit, these measures describe surgeon-level procedural distribution, not
hospital or health-system market competition.

This distribution is relevant because higher surgeon volume has been
associated with better outcomes after midurethral sling surgery. Berger
et al. reported lower adjusted reoperation risk among higher-volume
surgeons,<sup>16</sup> and a systematic review found greater risks of
mesh revision and repeat incontinence procedures among low-volume
surgeons.<sup>17</sup> Other studies have reported lower revision odds
above approximately 50 cases per year<sup>18</sup> and better objective
cure rates with greater experience and annual volume.<sup>19</sup> The
fee-for-service Medicare medians of 15–19 observable services per year
cannot be compared directly with all-payer thresholds. The PUF excludes
younger patients, Medicare Advantage, commercial insurance, and
physician-years below the suppression threshold; total surgeon volume
may therefore exceed the observed Medicare count, but cannot be inferred
precisely.

### Temporal Trends and the Evolving SUI Landscape

The repeated-measures and participation analyses help explain the
changing specialty shares. Annual volume among observable physicians was
stable, but non-URPS participation declined while the URPS pool remained
comparatively stable. URPS also accounted for the largest number of
newly observable episodes. The shift therefore reflects a change in the
specialty composition of a contracting observable service pool, not
increasing individual volume or concentration.

This pattern is consistent with prior work. Siegal et al. found that the
post-2011 decline in sling placement was driven mainly by non-FPMRS
providers, whereas FPMRS providers maintained their volume.<sup>12</sup>
Lee et al. documented an approximately 50% national decline in
incontinence surgery from 2004 through 2013.<sup>13</sup> In the present
study, the 2020 decrease (RR 0.87) was consistent with pandemic-related
deferral of elective surgery, and the principal specialty comparisons
were similar when 2020 was excluded.

The SUI treatment landscape is also evolving. Urethral bulking is
increasingly used as a less-invasive procedural alternative for selected
patients, although efficacy is generally lower and repeat treatment may
be required,<sup>3,20</sup> and continued surveillance will be needed to
determine whether changing treatment preferences alter
specialty-specific sling volume.

### Limitations

This study has several limitations. First, CMS suppresses records for
clinicians treating fewer than 11 beneficiaries, so the lowest-volume
physician-years are not observed. Full-market concentration cannot be
identified, and the sensitivity analysis supports only the narrower
conclusion that observable services were not dominated by a handful of
surgeons. Second, the PUF includes only fee-for-service Medicare Part B
claims. It excludes Medicare Advantage, commercial insurance, Medicaid,
uninsured care, and most younger patients.

Third, specialty classification depends on annual CMS provider type and
ABOG and ABU roster linkage. Fellowship-trained physicians who were not
board certified may be misclassified, and the Other/uncertain group
contains nonphysician and incompletely classified individual billers.
Although organizational NPIs were excluded and alternative handling of
ambiguous billers was examined, residual misclassification is possible.
Fourth, the market-share trend is not point identified. Fixed membership
assigns eventual subspecialty status to pre-certification years, whereas
certification-gated classification may assign genuine subspecialty
practice to an earlier general category. We therefore present these as
plausible scenarios rather than formal bounds.

Approximately 8% of URPS physicians lacked a matched certification year,
and urology-pathway URPS status remained fixed because a urology
subspecialty certification date was unavailable. Finally, reported
line-service units (Tot_Srvcs) may not correspond exactly to unique
operations because of claim-line, unit-count, and modifier conventions,
and should be interpreted as reported services rather than unique
operations.

### Strengths

Strengths include a national sample of publicly reported, nonsuppressed
fee-for-service provider-service records; identification of URPS
physicians through both certification pathways; explicit separation of
organizational and ambiguous billers; within-year and pooled
concentration measures with bootstrap confidence intervals; models that
account for repeated physician observations; multiple classification
sensitivities; and a fully reproducible analytic pipeline.

## Conclusions

Among physician-years observable in fee-for-service Medicare, URPS
physicians performed most reported sling services for stress urinary
incontinence, and their share increased from 2013 through 2023. The
increase was driven primarily by the OB/GYN pathway and declining
observable participation among non-URPS clinicians, not by increasing
surgeon-level concentration. Because the PUF excludes low-volume
physician-years and Medicare Advantage claims and does not distinguish
synthetic midurethral from fascial sling procedures, these results
describe observable Medicare service patterns rather than the complete
national sling market or clinical workforce. All-payer studies linking
volume, outcomes, and geographic access are needed before drawing
credentialing conclusions.

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
Specialty-specific physician counts exceed 1,467 because 13 physicians
changed groups across years. \*MIGS estimates are descriptive because
only 10 physicians were identified.

| Specialty | Unique physicians | Physician-years | Reported services | % of all | Median vol (p25-p75) | 2013 share | 2023 share | Delta share/yr (95% CI) | p |
|----|----|----|----|----|----|----|----|----|----|
| URPS, OB/GYN pathway | 616 | 3,272 | 77,501 | 59.8% | 19 (14–29) | 48.6% | 67.1% | +1.86 (1.44 to 2.28) | \<0.001 |
| URPS, urology pathway | 151 | 641 | 12,272 | 9.5% | 16 (13–22) | 9.9% | 8.2% | -0.28 (-0.44 to -0.11) | 0.004 |
| Urology (non-URPS) | 366 | 1,150 | 20,475 | 15.8% | 15 (12–20) | 23.9% | 9.2% | -1.32 (-1.62 to -1.01) | \<0.001 |
| Other non-URPS OB/GYN | 337 | 954 | 18,328 | 14.2% | 15 (12–22) | 17.4% | 14.5% | -0.36 (-0.64 to -0.08) | 0.017 |
| MIGS | 10 | 39 | 941 | 0.7% | 16 (12–24) | 0.2% | 1.0% | +0.09 (0.04 to 0.14)\* | 0.003 |
| **Total** | **1,467** | **6,056** | **129,517** | **100%** | n/a | n/a | n/a | n/a | n/a |

**Table 2.** Surgeon-level procedural concentration by specialty, based
on aggregate provider volume. Raw HHI is not comparable across groups of
different size; the normalized HHI (0–1) and effective number of
providers are size-adjusted companions.

| Specialty | N providers | Gini | HHI (0-10,000) | Normalized HHI | Effective providers | % by top 10% | % by top 20% |
|----|----|----|----|----|----|----|----|
| URPS, OB/GYN pathway | 616 | 0.51 | 33 | 0.002 | 305 | 33.6% | 53.0% |
| URPS, urology pathway | 151 | 0.53 | 149 | 0.008 | 67 | 36.2% | 56.9% |
| Urology (non-URPS) | 366 | 0.52 | 65 | 0.004 | 155 | 38.6% | 58.1% |
| Other non-URPS OB/GYN | 337 | 0.56 | 89 | 0.006 | 112 | 44.3% | 62.2% |
| MIGS | 10 | 0.61 | 3,036 | 0.226 | 3 | 49.8% | 69.3% |

**Table 3.** Adjusted rate ratios for annual reported services from a
Poisson GEE clustered by NPI (OB/GYN-pathway URPS reference; calendar
year centered at 2018; exchangeable correlation; robust standard
errors). The first block gives specialty contrasts at mid-study and the
2020 effect; the second block gives each specialty’s annual trend as a
marginal contrast (the year term plus its specialty-by-year
interaction).

| Term                                           | Rate ratio (95% CI) | p-value |
|------------------------------------------------|---------------------|---------|
| URPS urology vs URPS OB/GYN (at 2018)          | 0.75 (0.66–0.84)    | \<0.001 |
| Non-URPS urology vs URPS OB/GYN (at 2018)      | 0.70 (0.58–0.84)    | \<0.001 |
| Other non-URPS OB/GYN vs URPS OB/GYN (at 2018) | 0.60 (0.38–0.94)    | 0.026   |
| MIGS vs URPS OB/GYN (at 2018)                  | 0.78 (0.47–1.31)    | 0.350   |
| 2020 (COVID) indicator                         | 0.87 (0.84–0.91)    | \<0.001 |
| Annual trend, URPS (OB/GYN)                    | 0.999 (0.990-1.007) | 0.794   |
| Annual trend, URPS (urology)                   | 0.988 (0.974-1.002) | 0.091   |
| Annual trend, non-URPS urology                 | 0.986 (0.968-1.004) | 0.132   |
| Annual trend, other non-URPS OB/GYN            | 0.996 (0.972-1.021) | 0.764   |
| Annual trend, MIGS                             | 1.086 (1.032-1.142) | 0.002   |

**Table 4.** All-pathway URPS and OB/GYN-based market-share trends under
alternative classification scenarios. The scenarios differ in the
estimated rate of increase: fixed membership gives the shallower slope
because it counts physicians as URPS before certification, and
certification-gated classification gives the steeper slope because it
removes not-yet-certified physicians from the early URPS count. The 2023
levels converge. These are plausible scenarios rather than formal
statistical bounds. All estimated URPS trends are positive and
statistically significant.

| Analysis | 2013 -\> 2023 | Slope (pp/year) | p-value |
|----|----|----|----|
| Fixed membership: OB/GYN-based share (ABOG-URPS + MIGS + Gen OB/GYN) | 66.2% → 82.6% | 1.59 | \<0.001 |
| Fixed membership: all-pathway URPS share | 58.6% → 75.4% | 1.59 | \<0.001 |
| Modal: URPS share | n/a | 1.68 | \<0.001 |
| Ever-URPS/MIGS: URPS share | n/a | 1.65 | \<0.001 |
| **Certification-gated: URPS share (time-varying)** | **46.3% → 74.2%** | **2.26** | **\<0.001** |
| Certification-gated: OB/GYN-based share (time-varying) | n/a | 1.32 | \<0.001 |

------------------------------------------------------------------------

## Figures

<img
src="/Users/tylermuffly/sling-volume-patterns/output/figures/figure_rate_per_100k.png"
style="width:6.5in" />

**Figure 1.** Utilization of sling surgery for stress urinary
incontinence (CPT 57288) in fee-for-service Medicare, 2013–2023. Bars
show reported services; the line shows the denominator-adjusted rate per
100,000 female Part B fee-for-service beneficiaries. The rate declined
less than the raw count (-18.8% versus -30.7%) because the
fee-for-service population contracted by -14.7%; the linear trend in the
rate was not significant (p = 0.052).

<img
src="/Users/tylermuffly/sling-volume-patterns/output/figures/figure_market_share.png"
style="width:6.5in" />

**Figure 2.** Market share of sling operations for stress urinary
incontinence (CPT 57288) by specialty, fee-for-service Medicare PUF
2013–2023. Stacked areas are the fixed-membership specialty shares; the
two black lines are the URPS share under fixed-membership (solid) and
certification-gated (dashed) classification. Fixed membership
(all-pathway URPS share 58.6% to 75.4%; +1.59 percentage points/year)
and certification-gated classification (46.3% to 74.2%; +2.26 percentage
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

| Year | Specialty | N surgeons | N procedures | Median (p25–p75) | Gini | HHI | Top 10% | Top 20% | Bottom 50% |
|----|----|----|----|----|----|----|----|----|----|
| 2013 | All | 742 | 14939 | 16 (13–23) | 0.268 | 17.9 | 24.1% | 38.7% | 31.9% |
| 2013 | MIGS | 3 | 35 | 12 (12–12) | 0.019 | 3338.8 | 34.3% | 34.3% | 31.4% |
| 2013 | General OB/GYN | 143 | 2592 | 14 (12–20) | 0.256 | 92.5 | 25.1% | 38.9% | 32.8% |
| 2013 | Urology | 211 | 3563 | 15 (12–19) | 0.198 | 55.9 | 20.8% | 33.7% | 36.3% |
| 2013 | URPS (OB/GYN) | 304 | 7266 | 19 (14–29) | 0.294 | 44.3 | 24.2% | 39.4% | 29.8% |
| 2013 | URPS (urology) | 81 | 1483 | 16 (14–20) | 0.199 | 146.1 | 22.0% | 34.3% | 36.2% |
| 2014 | All | 625 | 12963 | 17 (13–24) | 0.264 | 20.7 | 23.0% | 37.9% | 31.9% |
| 2014 | MIGS | 3 | 41 | 13 (12–15) | 0.098 | 3444.4 | 41.5% | 41.5% | 26.8% |
| 2014 | General OB/GYN | 114 | 2076 | 15 (12–21) | 0.239 | 108.2 | 22.8% | 36.6% | 33.6% |
| 2014 | Urology | 152 | 2577 | 15 (12–19) | 0.198 | 77.1 | 21.0% | 33.6% | 36.6% |
| 2014 | URPS (OB/GYN) | 290 | 6952 | 20 (15–30) | 0.275 | 44.8 | 22.7% | 37.8% | 30.9% |
| 2014 | URPS (urology) | 66 | 1317 | 16 (13–23) | 0.250 | 188.7 | 22.9% | 38.6% | 32.5% |
| 2015 | All | 586 | 11867 | 16 (13–23) | 0.265 | 22.4 | 23.3% | 38.1% | 32.0% |
| 2015 | MIGS | 5 | 66 | 12 (11–15) | 0.097 | 2066.1 | 25.8% | 25.8% | 33.3% |
| 2015 | General OB/GYN | 95 | 1774 | 15 (12–20) | 0.248 | 135.5 | 23.7% | 37.8% | 33.1% |
| 2015 | Urology | 129 | 2109 | 14 (12–18) | 0.196 | 92.2 | 20.2% | 33.6% | 36.5% |
| 2015 | URPS (OB/GYN) | 290 | 6678 | 19 (14–27) | 0.278 | 45.2 | 22.9% | 38.3% | 30.8% |
| 2015 | URPS (urology) | 67 | 1240 | 15 (12–24) | 0.236 | 185.7 | 21.5% | 36.5% | 33.1% |
| 2016 | All | 616 | 13250 | 17 (13–25) | 0.270 | 21.4 | 23.8% | 38.2% | 31.6% |
| 2016 | MIGS | 4 | 62 | 14 (12–18) | 0.161 | 2731.5 | 37.1% | 37.1% | 37.1% |
| 2016 | General OB/GYN | 97 | 1858 | 15 (13–22) | 0.247 | 133.1 | 23.1% | 37.7% | 32.7% |
| 2016 | Urology | 129 | 2225 | 15 (13–20) | 0.199 | 94.9 | 20.3% | 33.3% | 36.3% |
| 2016 | URPS (OB/GYN) | 314 | 7675 | 20 (14–29) | 0.281 | 41.7 | 23.4% | 38.3% | 30.5% |
| 2016 | URPS (urology) | 72 | 1430 | 16 (14–23) | 0.241 | 181.3 | 24.3% | 37.1% | 33.8% |
| 2017 | All | 639 | 14085 | 18 (13–26) | 0.281 | 20.9 | 23.7% | 38.9% | 30.7% |
| 2017 | MIGS | 3 | 79 | 15 (14–34) | 0.338 | 4923.9 | 65.8% | 65.8% | 15.2% |
| 2017 | General OB/GYN | 95 | 1925 | 16 (13–24) | 0.269 | 143.0 | 25.4% | 38.4% | 31.5% |
| 2017 | Urology | 126 | 2341 | 15 (12–21) | 0.249 | 109.3 | 24.0% | 37.7% | 33.3% |
| 2017 | URPS (OB/GYN) | 341 | 8217 | 20 (14–30) | 0.285 | 38.4 | 23.0% | 38.7% | 30.0% |
| 2017 | URPS (urology) | 74 | 1523 | 17 (14–24) | 0.246 | 169.4 | 22.9% | 36.0% | 32.9% |
| 2018 | All | 585 | 13171 | 19 (14–28) | 0.275 | 22.4 | 23.0% | 37.8% | 30.9% |
| 2018 | MIGS | 4 | 126 | 21 (20–33) | 0.278 | 3445.5 | 51.6% | 51.6% | 31.0% |
| 2018 | General OB/GYN | 82 | 1611 | 18 (13–23) | 0.241 | 155.3 | 23.5% | 36.2% | 33.5% |
| 2018 | Urology | 112 | 2195 | 16 (13–24) | 0.257 | 117.5 | 23.6% | 37.7% | 32.3% |
| 2018 | URPS (OB/GYN) | 327 | 8069 | 21 (15–32) | 0.280 | 39.6 | 22.3% | 37.6% | 30.1% |
| 2018 | URPS (urology) | 60 | 1170 | 16 (14–24) | 0.224 | 202.3 | 20.1% | 34.1% | 34.4% |
| 2019 | All | 558 | 12720 | 19 (14–27) | 0.275 | 23.4 | 23.5% | 38.2% | 31.1% |
| 2019 | MIGS | 5 | 168 | 25 (16–34) | 0.333 | 2913.1 | 45.8% | 45.8% | 19.0% |
| 2019 | General OB/GYN | 85 | 1757 | 17 (13–25) | 0.275 | 156.8 | 24.6% | 38.6% | 30.6% |
| 2019 | Urology | 82 | 1621 | 16 (13–24) | 0.239 | 152.7 | 22.9% | 36.4% | 33.5% |
| 2019 | URPS (OB/GYN) | 328 | 8059 | 20 (15–29) | 0.277 | 39.4 | 22.7% | 38.2% | 31.0% |
| 2019 | URPS (urology) | 58 | 1115 | 16 (13–24) | 0.225 | 215.0 | 21.3% | 35.3% | 34.6% |
| 2020 | All | 385 | 8013 | 17 (13–24) | 0.259 | 33.2 | 23.0% | 37.3% | 32.3% |
| 2020 | MIGS | 2 | 81 | 40 (34–47) | 0.154 | 5476.3 | 65.4% | 65.4% | 34.6% |
| 2020 | General OB/GYN | 46 | 941 | 17 (13–24) | 0.250 | 274.4 | 23.5% | 38.8% | 33.3% |
| 2020 | Urology | 57 | 940 | 14 (12–19) | 0.192 | 204.4 | 20.2% | 34.0% | 36.3% |
| 2020 | URPS (OB/GYN) | 243 | 5379 | 19 (14–26) | 0.265 | 52.6 | 23.1% | 37.7% | 31.6% |
| 2020 | URPS (urology) | 37 | 672 | 17 (12–19) | 0.216 | 331.5 | 22.6% | 36.2% | 34.4% |
| 2021 | All | 385 | 8051 | 17 (13–24) | 0.269 | 33.8 | 23.5% | 38.2% | 31.5% |
| 2021 | MIGS | 3 | 97 | 18 (16–41) | 0.337 | 4936.8 | 66.0% | 66.0% | 15.5% |
| 2021 | General OB/GYN | 58 | 1076 | 15 (12–20) | 0.268 | 238.9 | 25.8% | 40.6% | 32.6% |
| 2021 | Urology | 42 | 764 | 16 (13–23) | 0.207 | 274.6 | 21.9% | 34.8% | 35.5% |
| 2021 | URPS (OB/GYN) | 250 | 5523 | 18 (14–27) | 0.271 | 51.3 | 22.6% | 38.0% | 31.3% |
| 2021 | URPS (urology) | 32 | 591 | 16 (12–20) | 0.234 | 397.4 | 26.1% | 38.1% | 33.8% |
| 2022 | All | 469 | 10109 | 17 (13–25) | 0.274 | 28.2 | 24.0% | 38.8% | 31.4% |
| 2022 | MIGS | 3 | 87 | 17 (14–38) | 0.352 | 5016.5 | 66.7% | 66.7% | 13.8% |
| 2022 | General OB/GYN | 63 | 1218 | 15 (13–21) | 0.257 | 206.2 | 25.5% | 39.0% | 32.2% |
| 2022 | Urology | 62 | 1192 | 17 (13–22) | 0.223 | 195.4 | 22.1% | 35.8% | 34.9% |
| 2022 | URPS (OB/GYN) | 292 | 6734 | 19 (14–27) | 0.287 | 45.7 | 24.2% | 39.7% | 30.4% |
| 2022 | URPS (urology) | 49 | 878 | 16 (13–20) | 0.194 | 239.3 | 20.0% | 33.1% | 36.3% |
| 2023 | All | 466 | 10349 | 18 (14–26) | 0.270 | 27.7 | 22.9% | 38.1% | 31.5% |
| 2023 | MIGS | 4 | 99 | 14 (12–27) | 0.381 | 4204.7 | 60.6% | 60.6% | 23.2% |
| 2023 | General OB/GYN | 76 | 1500 | 16 (13–23) | 0.248 | 163.9 | 22.7% | 37.7% | 32.7% |
| 2023 | Urology | 48 | 948 | 17 (13–23) | 0.236 | 253.9 | 20.9% | 35.9% | 33.3% |
| 2023 | URPS (OB/GYN) | 293 | 6949 | 20 (15–28) | 0.275 | 44.2 | 23.1% | 38.4% | 31.0% |
| 2023 | URPS (urology) | 45 | 853 | 16 (12–23) | 0.227 | 264.9 | 21.7% | 34.2% | 33.1% |

**Supplementary Table S2.** Trend regressions for annual concentration
and volume measures on calendar year, overall and by specialty (ordinary
least squares).

| Measure | Specialty | Start | End | Slope / year | R-squared | p-value |
|----|----|----|----|----|----|----|
| Total procedures | All | 14939.000 | 10349.000 | -524.118 | 0.553 | 0.009 |
| Total procedures | General OB/GYN | 2592.000 | 1500.000 | -118.073 | 0.680 | 0.002 |
| Total procedures | MIGS | 35.000 | 99.000 | 6.582 | 0.333 | 0.060 |
| Total procedures | URPS (OB/GYN) | 7266.000 | 6949.000 | -97.018 | 0.112 | 0.310 |
| Total procedures | URPS (urology) | 1483.000 | 853.000 | -79.791 | 0.663 | 0.002 |
| Total procedures | Urology | 3563.000 | 948.000 | -235.818 | 0.834 | n/a |
| Observable surgeons | All | 742.000 | 466.000 | -28.636 | 0.719 | n/a |
| Observable surgeons | General OB/GYN | 143.000 | 76.000 | -6.927 | 0.719 | n/a |
| Observable surgeons | MIGS | 3.000 | 4.000 | -0.027 | 0.009 | 0.780 |
| Observable surgeons | URPS (OB/GYN) | 304.000 | 293.000 | -2.927 | 0.100 | 0.340 |
| Observable surgeons | URPS (urology) | 81.000 | 45.000 | -3.991 | 0.702 | 0.001 |
| Observable surgeons | Urology | 211.000 | 48.000 | -14.764 | 0.889 | n/a |
| Median annual volume | All | 16.000 | 18.000 | 0.127 | 0.169 | 0.210 |
| Median annual volume | General OB/GYN | 14.000 | 16.000 | 0.136 | 0.169 | 0.210 |
| Median annual volume | MIGS | 12.000 | 14.000 | 0.973 | 0.148 | 0.240 |
| Median annual volume | URPS (OB/GYN) | 19.000 | 20.000 | -0.036 | 0.022 | 0.670 |
| Median annual volume | URPS (urology) | 16.000 | 16.000 | 0.036 | 0.036 | 0.580 |
| Median annual volume | Urology | 15.000 | 17.000 | 0.209 | 0.462 | 0.020 |
| Gini coefficient | All | 0.268 | 0.270 | 0.000 | 0.024 | 0.650 |
| Gini coefficient | General OB/GYN | 0.256 | 0.248 | 0.001 | 0.067 | 0.440 |
| Gini coefficient | MIGS | 0.019 | 0.381 | 0.032 | 0.692 | 0.002 |
| Gini coefficient | URPS (OB/GYN) | 0.294 | 0.275 | -0.001 | 0.177 | 0.200 |
| Gini coefficient | URPS (urology) | 0.199 | 0.227 | -0.001 | 0.070 | 0.430 |
| Gini coefficient | Urology | 0.198 | 0.236 | 0.003 | 0.139 | 0.260 |
| HHI (0–10,000) | All | 17.906 | 27.700 | 1.265 | 0.639 | 0.003 |
| HHI (0–10,000) | General OB/GYN | 92.503 | 163.902 | 12.324 | 0.554 | 0.009 |
| HHI (0–10,000) | MIGS | 3338.776 | 4204.673 | 206.443 | 0.379 | 0.040 |
| HHI (0–10,000) | URPS (OB/GYN) | 44.322 | 44.229 | 0.404 | 0.085 | 0.380 |
| HHI (0–10,000) | URPS (urology) | 146.115 | 264.909 | 16.159 | 0.501 | 0.010 |
| HHI (0–10,000) | Urology | 55.876 | 253.877 | 20.658 | 0.861 | n/a |
| Share by top 10% (%) | All | 24.085 | 22.930 | -0.031 | 0.057 | 0.480 |
| Share by top 10% (%) | General OB/GYN | 25.077 | 22.733 | 0.050 | 0.021 | 0.670 |
| Share by top 10% (%) | MIGS | 34.286 | 60.606 | 3.543 | 0.623 | 0.004 |
| Share by top 10% (%) | URPS (OB/GYN) | 24.250 | 23.097 | -0.016 | 0.007 | 0.800 |
| Share by top 10% (%) | URPS (urology) | 21.982 | 21.688 | -0.036 | 0.005 | 0.840 |
| Share by top 10% (%) | Urology | 20.797 | 20.886 | 0.082 | 0.039 | 0.560 |
| Share by top 20% (%) | All | 38.717 | 38.100 | -0.020 | 0.019 | 0.680 |
| Share by top 20% (%) | General OB/GYN | 38.850 | 37.667 | 0.132 | 0.131 | 0.270 |
| Share by top 20% (%) | MIGS | 34.286 | 60.606 | 3.543 | 0.623 | 0.004 |
| Share by top 20% (%) | URPS (OB/GYN) | 39.403 | 38.365 | -0.004 | 0.000 | 0.950 |
| Share by top 20% (%) | URPS (urology) | 34.322 | 34.232 | -0.185 | 0.123 | 0.290 |
| Share by top 20% (%) | Urology | 33.679 | 35.865 | 0.215 | 0.189 | 0.180 |
| Share by bottom 50% (%) | All | 31.950 | 31.520 | -0.034 | 0.054 | 0.490 |
| Share by bottom 50% (%) | General OB/GYN | 32.832 | 32.667 | -0.070 | 0.070 | 0.430 |
| Share by bottom 50% (%) | MIGS | 31.429 | 23.232 | -1.345 | 0.270 | 0.100 |
| Share by bottom 50% (%) | URPS (OB/GYN) | 29.769 | 31.026 | 0.084 | 0.233 | 0.130 |
| Share by bottom 50% (%) | URPS (urology) | 36.210 | 33.060 | 0.043 | 0.012 | 0.740 |
| Share by bottom 50% (%) | Urology | 36.290 | 33.333 | -0.220 | 0.216 | 0.150 |

**Supplementary Table S3.** Specialty-specific market-share trends. Each
specialty’s annual share of observed procedures is regressed on calendar
year separately (fixed-membership classification).

| Specialty      | 2013 share (%) | 2023 share (%) | Slope (pp/yr) | p-value |
|----------------|----------------|----------------|---------------|---------|
| General OB/GYN | 17.4           | 14.5           | -0.357        | 0.017   |
| MIGS           | 0.2            | 1.0            | 0.087         | 0.003   |
| URPS (OB/GYN)  | 48.6           | 67.1           | 1.863         | \<0.001 |
| URPS (urology) | 9.9            | 8.2            | -0.277        | 0.004   |
| Urology        | 23.9           | 9.2            | -1.315        | \<0.001 |

**Supplementary Table S4.** Adjusted rate ratios for annual sling volume
from a Poisson GEE clustered by NPI, excluding calendar year 2020
(COVID-19 sensitivity analysis; URPS reference).

| Term                             | RR (95% CI)         | p-value |
|----------------------------------|---------------------|---------|
| (Intercept)                      | 22.06 (20.24-24.06) | n/a     |
| Specialty: General OB/GYN        | 0.61 (0.41-0.93)    | 0.020   |
| Specialty: MIGS                  | 0.88 (0.57-1.36)    | 0.560   |
| Specialty: Urology               | 0.68 (0.56-0.83)    | n/a     |
| Specialty: URPS (urology)        | 0.74 (0.67-0.82)    | n/a     |
| year_c                           | 1.00 (0.99-1.01)    | 0.850   |
| Specialty: General OB/GYN:year_c | 1.00 (0.97-1.02)    | 0.900   |
| Specialty: MIGS:year_c           | 1.08 (1.02-1.14)    | 0.005   |
| Specialty: Urology:year_c        | 0.99 (0.97-1.01)    | 0.220   |
| Specialty: URPS (urology):year_c | 0.99 (0.97-1.01)    | 0.210   |

**Supplementary Table S5.** Per-physician volume comparisons (one median
value per physician), Kruskal-Wallis and pairwise Wilcoxon tests with
Bonferroni correction.

| Test | Statistic | df | p-value |
|----|----|----|----|
| Kruskal-Wallis: per-physician median volume across specialties | 96.34 | 4 | \<0.001 |
| Wilcoxon (per-physician, bonferroni): MIGS vs General OB/GYN | n/a | NA | 1.00 |
| Wilcoxon (per-physician, bonferroni): Urology vs General OB/GYN | n/a | NA | 1.00 |
| Wilcoxon (per-physician, bonferroni): Urology vs MIGS | n/a | NA | 1.00 |
| Wilcoxon (per-physician, bonferroni): URPS (OB/GYN) vs General OB/GYN | n/a | NA | \<0.001 |
| Wilcoxon (per-physician, bonferroni): URPS (OB/GYN) vs MIGS | n/a | NA | 1.00 |
| Wilcoxon (per-physician, bonferroni): URPS (OB/GYN) vs Urology | n/a | NA | \<0.001 |
| Wilcoxon (per-physician, bonferroni): URPS (urology) vs General OB/GYN | n/a | NA | 0.90 |
| Wilcoxon (per-physician, bonferroni): URPS (urology) vs MIGS | n/a | NA | 1.00 |
| Wilcoxon (per-physician, bonferroni): URPS (urology) vs Urology | n/a | NA | 0.57 |
| Wilcoxon (per-physician, bonferroni): URPS (urology) vs URPS (OB/GYN) | n/a | NA | \<0.001 |

**Supplementary Table S6a.** Specialty distribution under alternative
classification schemes (time-varying, modal, ever-URPS/MIGS,
certification-gated).

| Scheme | Specialty | N providers | Procedures | % of all |
|----|----|----|----|----|
| Time-varying (per physician-year) | General OB/GYN | 336 | 18316 | 13.0% |
| Time-varying (per physician-year) | MIGS | 10 | 941 | 0.7% |
| Time-varying (per physician-year) | Other/uncertain | 200 | 11504 | 8.2% |
| Time-varying (per physician-year) | URPS | 767 | 89773 | 63.7% |
| Time-varying (per physician-year) | Urology | 366 | 20475 | 14.5% |
| Modal (single most-frequent specialty) | General OB/GYN | 332 | 18287 | 13.0% |
| Modal (single most-frequent specialty) | MIGS | 10 | 941 | 0.7% |
| Modal (single most-frequent specialty) | Other/uncertain | 200 | 11504 | 8.2% |
| Modal (single most-frequent specialty) | URPS | 766 | 90107 | 63.9% |
| Modal (single most-frequent specialty) | Urology | 358 | 20170 | 14.3% |
| Ever URPS/MIGS | General OB/GYN | 332 | 18287 | 13.0% |
| Ever URPS/MIGS | MIGS | 10 | 941 | 0.7% |
| Ever URPS/MIGS | Other/uncertain | 200 | 11504 | 8.2% |
| Ever URPS/MIGS | URPS | 767 | 90686 | 64.3% |
| Ever URPS/MIGS | Urology | 357 | 19591 | 13.9% |
| Time-varying cert-gated (ABOG sub1startdate) | General OB/GYN | 533 | 27453 | 19.5% |
| Time-varying cert-gated (ABOG sub1startdate) | MIGS | 5 | 201 | 0.1% |
| Time-varying cert-gated (ABOG sub1startdate) | Other/uncertain | 200 | 11492 | 8.1% |
| Time-varying cert-gated (ABOG sub1startdate) | URPS | 716 | 83348 | 59.1% |
| Time-varying cert-gated (ABOG sub1startdate) | Urology | 353 | 18515 | 13.1% |

**Supplementary Table S6b.** All-pathway URPS and OB/GYN-based
market-share trends under each classification scheme. The URPS increase
remains positive and significant in every scheme.

| Scheme | URPS slope (pp/yr) | URPS p | Gyn slope (pp/yr) | Gyn p |
|----|----|----|----|----|
| Time-varying (per physician-year) | 1.116 | \<0.001 | 0.796 | \<0.001 |
| Modal (single most-frequent specialty) | 1.200 | \<0.001 | 0.906 | \<0.001 |
| Ever URPS/MIGS | 1.174 | \<0.001 | 0.881 | \<0.001 |
| Time-varying cert-gated (ABOG sub1startdate) | 1.762 | \<0.001 | 0.792 | \<0.001 |

**Supplementary Table S7.** Observable surgeons and URPS share by
provider practice state (geography, secondary analysis). A state with no
observable URPS surgeon may still have URPS surgeons who each fell below
the CMS reporting threshold.

| State | Observable surgeons | URPS surgeons | URPS share | Observable URPS? |
|-------|---------------------|---------------|------------|------------------|
| TX    | 120                 | 47            | 39.2%      | Yes              |
| CA    | 106                 | 50            | 47.2%      | Yes              |
| FL    | 98                  | 49            | 50.0%      | Yes              |
| NY    | 65                  | 41            | 63.1%      | Yes              |
| IL    | 61                  | 39            | 63.9%      | Yes              |
| OH    | 56                  | 44            | 78.6%      | Yes              |
| PA    | 53                  | 33            | 62.3%      | Yes              |
| MI    | 51                  | 22            | 43.1%      | Yes              |
| MA    | 50                  | 33            | 66.0%      | Yes              |
| NC    | 49                  | 35            | 71.4%      | Yes              |
| TN    | 47                  | 20            | 42.6%      | Yes              |
| NJ    | 44                  | 28            | 63.6%      | Yes              |
| AZ    | 41                  | 19            | 46.3%      | Yes              |
| MO    | 38                  | 16            | 42.1%      | Yes              |
| GA    | 37                  | 17            | 45.9%      | Yes              |
| VA    | 37                  | 27            | 73.0%      | Yes              |
| WA    | 36                  | 19            | 52.8%      | Yes              |
| IN    | 33                  | 13            | 39.4%      | Yes              |
| AL    | 30                  | 12            | 40.0%      | Yes              |
| SC    | 29                  | 11            | 37.9%      | Yes              |
| MD    | 28                  | 14            | 50.0%      | Yes              |
| LA    | 26                  | 6             | 23.1%      | Yes              |
| OK    | 26                  | 10            | 38.5%      | Yes              |
| KY    | 24                  | 10            | 41.7%      | Yes              |
| CO    | 21                  | 14            | 66.7%      | Yes              |
| NV    | 20                  | 8             | 40.0%      | Yes              |
| OR    | 20                  | 9             | 45.0%      | Yes              |
| AR    | 19                  | 3             | 15.8%      | Yes              |
| WI    | 19                  | 12            | 63.2%      | Yes              |
| NE    | 18                  | 4             | 22.2%      | Yes              |
| CT    | 17                  | 14            | 82.4%      | Yes              |
| KS    | 15                  | 4             | 26.7%      | Yes              |
| IA    | 13                  | 7             | 53.8%      | Yes              |
| MN    | 13                  | 11            | 84.6%      | Yes              |
| MS    | 10                  | 3             | 30.0%      | Yes              |
| NM    | 10                  | 5             | 50.0%      | Yes              |
| UT    | 9                   | 3             | 33.3%      | Yes              |
| ME    | 8                   | 6             | 75.0%      | Yes              |
| NH    | 8                   | 5             | 62.5%      | Yes              |
| WV    | 8                   | 3             | 37.5%      | Yes              |
| DC    | 6                   | 5             | 83.3%      | Yes              |
| RI    | 6                   | 5             | 83.3%      | Yes              |
| SD    | 6                   | 3             | 50.0%      | Yes              |
| DE    | 5                   | 4             | 80.0%      | Yes              |
| ID    | 4                   | 3             | 75.0%      | Yes              |
| HI    | 3                   | 3             | 100.0%     | Yes              |
| MT    | 3                   | 2             | 66.7%      | Yes              |
| VT    | 3                   | 2             | 66.7%      | Yes              |
| ND    | 2                   | 0             | 0.0%       | No               |
| PR    | 2                   | 0             | 0.0%       | No               |
| AK    | 1                   | 0             | 0.0%       | No               |
| WY    | 1                   | 0             | 0.0%       | No               |

**Supplementary Table S8.** Suppression illustration (not an empirically
estimated sensitivity). Hypothetical suppressed low-volume clinicians
(25% and 50% of the observed count, each performing 1–10 services) were
added to each group before recomputing the Gini coefficient and HHI.
Adding these clinicians increased estimated inequality, particularly in
the 50% scenario, while HHI remained low. Because neither the number nor
the volume distribution of suppressed clinicians is known, these
illustrations do not identify full-market concentration; they support
only the narrower conclusion that observable services were not dominated
by a handful of surgeons.

| Specialty | Observed Gini | Gini +25% suppressed | Gini +50% suppressed | Observed HHI | HHI +50% suppressed |
|----|----|----|----|----|----|
| URPS (OB/GYN) | 0.51 | 0.59 | 0.64 | 33 | 31 |
| URPS (urology) | 0.53 | 0.60 | 0.65 | 149 | 140 |
| Urology (non-URPS) | 0.52 | 0.59 | 0.62 | 65 | 59 |
| Other non-URPS OB/GYN | 0.56 | 0.62 | 0.65 | 89 | 81 |

**Supplementary Table S9.** Annual observable participation transitions
using a two-year washout. Newly observable surgeons were absent in both
prior observable years; surgeons no longer observable were absent in
both subsequent observable years. Newly observable and continuing counts
are undefined for the first two years, and no-longer-observable counts
are undefined for the last two years. These describe threshold
crossings, not definitive entry into or exit from practice.

| Year | Observable | Entrants | Continuing | Exiting | % volume by entrants | Median entrant volume |
|----|----|----|----|----|----|----|
| 2013 | 742 | n/a | n/a | 192 | n/a | n/a |
| 2014 | 625 | n/a | n/a | 148 | n/a | n/a |
| 2015 | 586 | 102 | 484 | 109 | 12.4% | 13 |
| 2016 | 616 | 124 | 492 | 109 | 13.5% | 13 |
| 2017 | 639 | 117 | 522 | 165 | 11.8% | 13 |
| 2018 | 585 | 110 | 475 | 130 | 12.5% | 14 |
| 2019 | 558 | 97 | 461 | 185 | 11.0% | 13 |
| 2020 | 385 | 34 | 351 | 56 | 5.5% | 12 |
| 2021 | 385 | 56 | 329 | 64 | 9.5% | 12 |
| 2022 | 469 | 131 | 338 | n/a | 20.2% | 14 |
| 2023 | 466 | 87 | 379 | n/a | 12.7% | 13 |

Newly observable episodes by specialty: URPS, 480; other OB/GYN, 205;
non-URPS urology, 165; MIGS, 8.

**Supplementary Table S11.** Classification sensitivity for ambiguous
and facility billers (reviewer concern). The primary analysis excludes
facility NPIs (NPPES entity type 2) and the remaining non-physician or
unclassifiable billers from the physician cohort. Retaining those
billers as a separate “Other/uncertain” group changes the well-populated
specialty shares only slightly, whereas assigning them to urology (the
legacy approach) roughly doubles the apparent non-URPS urology share.
The URPS increase is significant under all three.

| Handling of ambiguous billers | Physicians | URPS share | Non-URPS urology share |
|----|----|----|----|
| Excluded from the cohort (primary) | 1,467 | 69.3% | 15.8% |
| Retained as a separate ‘Other/uncertain’ group | 1,666 | 63.7% | 14.5% |
| Assigned to urology (legacy) | 1,789 | 60.8% | 26.1% |

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
