# data/raw/ — CMS Data Provenance

Pattern 4 from mkiang lab architecture: original source files live here,
**never modified after download**. All downstream scripts read from
`data/cache/` (processed artifacts) — never directly from this folder.

---

## CMS Medicare Physician & Other Practitioners Public Use File (PUF)

**Source:** CMS Provider Summary by Type of Service
**URL:** <https://data.cms.gov/provider-summary-by-type-of-service/medicare-physician-other-practitioners/medicare-physician-other-practitioners-by-provider-and-service>

| Year | File name | Download date | CMS release date | Rows (approx) |
|------|-----------|---------------|-----------------|----------------|
| 2017 | `Medicare_Provider_Utilization_2017.csv` | TBD | TBD | ~9.5M |
| 2018 | `Medicare_Provider_Utilization_2018.csv` | TBD | TBD | ~9.6M |
| 2019 | `Medicare_Provider_Utilization_2019.csv` | TBD | TBD | ~9.5M |
| 2020 | `Medicare_Provider_Utilization_2020.csv` | TBD | TBD | ~8.8M |
| 2021 | `Medicare_Provider_Utilization_2021.csv` | TBD | TBD | ~9.1M |
| 2022 | `Medicare_Provider_Utilization_2022.csv` | TBD | TBD | ~9.3M |
| 2023 | `Medicare_Provider_Utilization_2023.csv` | TBD | TBD | ~9.4M |

**Key columns used:**
- `Rndrng_NPI` — 10-digit National Provider Identifier
- `Rndrng_Prvdr_Type` — CMS-reported provider specialty type string
- `HCPCS_Cd` — HCPCS/CPT procedure code (filter to `57288`)
- `Tot_Srvcs` — Total Medicare-allowed services for that NPI × HCPCS × year

**CMS suppression policy:** Cells with 1–10 services are suppressed
(asterisk in CSV → `NA` after `readr::col_double()` parse).
Flagged as `is_cms_suppressed = TRUE` in Phase 1 output; NOT dropped
because provider existence and specialty remain valid.

---

## Verification

After downloading, run `tools::md5sum()` or `digest::digest(file=, algo="sha256")`
on each CSV and record hashes here to detect accidental modification:

```r
# Record provenance hash for a downloaded file:
digest::digest(
  file  = here::here("data", "raw", "Medicare_Provider_Utilization_2023.csv"),
  algo  = "sha256"
)
```

| Year | SHA-256 (fill in after download) |
|------|----------------------------------|
| 2017 | |
| 2018 | |
| 2019 | |
| 2020 | |
| 2021 | |
| 2022 | |
| 2023 | |

---

*This file should be updated each time a new PUF year is added.*
