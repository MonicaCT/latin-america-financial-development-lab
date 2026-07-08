# Data Audit

Last updated: 2026-07-08

## Executive Diagnosis

This repository contains legacy R scripts, LaTeX presentation files, and PDF
procedure notes for a Latin American credit dataset. It does not currently
version the raw or cleaned datasets needed to reproduce numerical results.

The legacy workflow appears to have been organized around three analytical data
products:

- `CreditType`: credit by product or credit type.
- `EconomicSector`: credit by productive economic sector.
- `PanelCompleto`: merged panel combining credit type and economic sector data.

The new reproducible structure keeps the original files untouched and adds a
documented R pipeline under `src/`.

## Repository Files Read

| File | Type | Function |
|---|---|---|
| `README.md` | Markdown | Original portfolio description; replaced with doctoral research README. |
| `1-LoadingData-s.R` | R | Downloads or scrapes source files by country for credit-type data. |
| `2-CountryData-s.R` | R | Cleans country-level credit-type files and builds `CreditType.final`. |
| `3-CountryFigures-s.R` | R | Generates country figures for credit-type indicators. |
| `4-CountryFigures-2-s.R` | R | Generates figures by credit type. |
| `1-CountryData.ES-s.R` | R | Builds economic-sector indices and inflation-adjusted indices. |
| `2-CountryFigures.ES-s.R` | R | Generates country figures for economic-sector credit. |
| `3-CountryFigures.ES-2-s.R` | R | Generates figures by economic sector. |
| `4-Analisis Total Productive-s.R` | R | Compares productive credit from credit-type and sector sources. |
| `1-CountryData_PanelCompleto-s.R` | R | Merges `CreditType` and `EconomicSector` into `PanelCompleto`. |
| `EconomicSector-CountryFigures.tex` | TeX | Beamer output for sector-credit country figures. |
| `EconomicSector-CountryFigures-ipc.tex` | TeX | Beamer output for inflation-adjusted sector-credit country figures. |
| `EconomicSector-Sectors-ipc.tex` | TeX | Beamer output for economic-sector figures. |
| `EconomicSector-TotalProductiveCredit.tex` | TeX | Beamer output for total productive credit comparisons. |
| `R code explanation.pdf` | PDF | Narrative explanation of the data download and update scripts. |
| `Proceditures-actualization-Credit-Type.pdf` | PDF | Procedure for credit-type database construction and updates. |
| `Proceditures-actualization-EconomicSector.pdf` | PDF | Procedure for economic-sector database construction and updates. |
| `Proceditures-actualization-PanelCompleto.pdf` | PDF | Procedure for merging credit-type and economic-sector databases. |

## Datasets Detected

| Dataset | Expected files | Status | Aggregation |
|---|---|---|---|
| CreditType | `CreditType_panel.xlsx`, `CreditType.final.xlsx`, `CreditType.final.csv` | Not committed | Country-month or country-date credit type panel. |
| EconomicSector | `EconomicSector_panel.xlsx`, `EconomicSector.final.xlsx`, `EconomicSector.final.csv` | Not committed | Country-month or country-date sector credit panel. |
| PanelCompleto | `PanelCompleto.final.xlsx`, `PanelCompleto.final.csv` | Not committed | Merged country-date panel. |
| IPC | `IPC.xlsx` | Not committed | Inflation index used for deflated credit indices. |
| Country backups | `old_tc*.csv`, `old_*.xls`, `old_*.xlsx` | Not committed | Country-specific historical inputs and backup panels. |

## Countries Detected

The scripts and TeX outputs explicitly reference Argentina, Bolivia,
Brazil/Brasil, Chile, Colombia, Costa Rica, Dominican Republic, Ecuador, El
Salvador, Guatemala, Honduras, Mexico, Nicaragua, Panama, Paraguay, Peru, and
Venezuela.

The sector presentations include Argentina, Bolivia, Brazil, Chile, Costa Rica,
Dominican Republic, El Salvador, Guatemala, Honduras, Mexico, Nicaragua, Panama,
Paraguay, and Peru. Some countries are commented out or appear only in
credit-type scripts.

## Years and Frequency

The committed files do not include data, so exact coverage cannot be verified.
The legacy procedures are dated December 2020 and refer to monthly updates.
The scripts build base-year indices using December 2018, sometimes December 2019
or 2020 for country-specific adjustments, especially Chile.

Actual first year, last year, observation counts, and missingness must be
computed once the raw or cleaned files are restored.

## Principal Variables Detected

Credit-type variables:

- `CommercialCredit`
- `ConsumerCredit`
- `CreditCard`
- `Mortgage`
- `Microcredit`
- `SMEs`
- `BusinessCredit`
- `Leasing`
- `Government`
- `PersonalCredit`
- `Total`
- `Totalem`

Economic-sector variables:

- `T.credit`
- `T.productive`
- `Industry`
- `Agricultural`
- `Commerce`
- `Individuals`
- `Remaining`

Common identifiers and transformations:

- `Country`
- `Date`
- `year`
- base-year nominal indices such as `iT.credit18`
- deflated indices such as `iT.credit18ipc`
- update diagnostics such as `old.obser`, `new.obser`, `Updated.obser`

## Problems Found

- Raw and cleaned data files are not committed.
- Several paths are absolute or tied to legacy local folders such as `/Final_*`.
- Original scripts mix downloading, cleaning, validation, and reporting in long
  monolithic files.
- Some country procedures require manual downloads or copy-paste steps.
- Variable definitions differ by country and are harmonized in code rather than
  in a central dictionary.
- Several legacy outputs point to image folders that are not present in the repo.
- Exact panel coverage, missing values, and descriptive statistics cannot be
  verified without the missing data files.
- R, Quarto, and Python were not available in the current execution environment,
  so rendering could not be executed locally during this audit.

## Assumptions Required

- `T.credit` is interpreted as total credit when present.
- `T.productive` is interpreted as productive credit when present.
- `T.credit - T.productive` is interpreted as non-productive credit only when
  both variables are available and comparable.
- Sector concentration is computed using observed sector shares from
  `Agricultural`, `Commerce`, `Industry`, and `Remaining` when available.
- Monthly data can be aggregated to annual indicators using annual means, unless
  a source-specific stock or end-of-year convention is documented.
- Cross-country currency comparisons should rely on indices or shares unless
  harmonized currency conversion or price deflation metadata are available.

## Improvements Applied

- Added a professional project structure: `docs/`, `data/`, `src/`, `outputs/`,
  `report/`, `dashboard/`, and `replication/`.
- Added a reproducible R pipeline with clear phases.
- Added metadata-first data discovery and load-status outputs.
- Added validation tables for panel coverage, missing values, variable
  dictionary, descriptive statistics, and country rankings.
- Added model and robustness scripts that document non-estimability instead of
  fabricating econometric results.
- Added a Shiny dashboard scaffold with data-quality visibility.
- Added a Quarto research report scaffold.
- Added explicit documentation for unavailable data and runtime constraints.

## Required Next Data Action

Restore the original data folders or place the cleaned panels in `data/raw/`.
The minimum useful files are:

- `CreditType.final.csv` or `CreditType.final.xlsx`
- `EconomicSector.final.csv` or `EconomicSector.final.xlsx`
- `PanelCompleto.final.csv` or `PanelCompleto.final.xlsx`

Then run `source("src/99_run_all.R")`.
