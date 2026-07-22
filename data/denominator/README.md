# Fee-for-service beneficiary denominator

Female Original Medicare (fee-for-service) enrollment by calendar year, for
computing CPT 57288 services per 100,000 female Part B FFS beneficiaries
(reviewer point #2: raw service counts lack an enrollment denominator).

## Source

**CMS Program Statistics - Original Medicare Enrollment** (data.cms.gov,
dataset `3997fb87-a6d5-41d0-823f-7a62283e8035`). Original Medicare = traditional
fee-for-service, excluding Medicare Advantage, so it matches the PUF numerator.

Table used: **MDCR ENROLL AB 11** ("Part A and/or Part B Enrollees by
Demographic Characteristics"), the `Sex -> Female` row. Columns captured:

| column | meaning |
|---|---|
| `female_ffs_partA_or_B` | female FFS enrollees with Part A and/or Part B |
| `female_ffs_partA_and_B` | female FFS enrollees with both Part A and Part B |
| `female_ffs_partB` | female FFS enrollees with Part B (primary denominator) |

**Confirmed primary denominator: `female_ffs_partB`** (enrolled in Part B, the
coverage a CPT 57288 claim requires). The other two columns are retained only
for sensitivity checks.

## Per-year download URLs (Original Medicare Enrollment zips, tables AB 9-14)

- 2013 https://data.cms.gov/sites/default/files/2020-01/2013_Org_Med_Enroll.zip
- 2014 https://data.cms.gov/sites/default/files/2020-01/2014_Org_Med_Enroll.zip
- 2015 https://data.cms.gov/sites/default/files/2020-01/2015_Org_Med_Enroll.zip
- 2016 https://data.cms.gov/sites/default/files/2020-01/2016_Org_Med_Enroll.zip
- 2017 https://data.cms.gov/sites/default/files/2019-12/2017_Org_Med_Enroll.zip
- 2018 https://data.cms.gov/sites/default/files/2020-11/CPS%20MDCR%20TOTAL%20ENROLL%20AB%209-14.zip
- 2019 https://data.cms.gov/sites/default/files/2021-01/CPS_MDCR_ENROLL_AB_9-14.zip
- 2020 https://data.cms.gov/sites/default/files/2022-02/CPS%20MDCR%20ENROLL%20AB%209-14%202020.zip
- 2021 https://data.cms.gov/sites/default/files/2023-02/CPS%20MDCR%20ENROLL%20AB%209-14%202021.zip
- 2022 https://data.cms.gov/sites/default/files/2025-09/02bff2a9-4874-4541-96ae-ac306d297f16/MDCR%20ENROLL%20AB%209-14_CPS_02ENR_2022.zip
- 2023 https://data.cms.gov/sites/default/files/2025-09/d3e2470b-f7ed-4c92-9615-4bfee94b6bdb/MDCR%20ENROLL%20AB%209-14_CPS_02ENR_2023.zip

Downloaded 2026-07-22. The AB 11 source workbooks are kept in `raw_ab11/`.

## Files

- `female_ffs_denominator.csv` - tidy: year, three coverage variants, source_file
- `raw_ab11/orig_med_enroll_ab_<year>.xlsx` - the AB 11 (or 9-14) source workbook

## Note on age standardization

The PUF numerator (CPT 57288 services) carries no beneficiary age, so the rate
cannot be age-standardized from these data; report a crude rate per 100,000
female Part B FFS beneficiaries, with absolute counts as a secondary measure.
