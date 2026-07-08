# Replication Guide

This repository now has two replication modes.

## Mode A: Reconstructed Public-Data Pipeline

Use this mode in the current environment. It does not require the missing legacy backup files.

From the repository root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\src\reconstruct_public_data.ps1 -Root (Resolve-Path .).Path
```

This command:

- redownloads official public sources where the legacy URLs still respond;
- downloads World Bank WDI JSON files;
- rebuilds `PanelCompleto.reconstructed.csv`, `CreditType.reconstructed.csv`, and `EconomicSector.reconstructed.csv`;
- regenerates figures, tables, OLS model outputs, dashboard HTML, paper, and executive report.

Expected core outputs:

- `data/processed/PanelCompleto.reconstructed.csv`
- `data/processed/CreditType.reconstructed.csv`
- `data/processed/EconomicSector.reconstructed.csv`
- `data/metadata/source_download_status.csv`
- `outputs/figures/figure_01_*.png` through `outputs/figures/figure_15_*.png`
- `outputs/tables/*.csv`
- `outputs/models/model_results.csv`
- `dashboard/index.html`
- `report/financial_development_report.html`
- `report/executive_report.html`

## Mode B: Exact Legacy Pipeline

Use this mode only if the original historical files are restored.

Place raw or cleaned data in `data/raw/`, `Data/`, `Data.ES/`, or the legacy subfolders using names such as:

- `PanelCompleto.final.csv` or `PanelCompleto.final.xlsx`
- `CreditType.final.csv` or `CreditType.final.xlsx`
- `EconomicSector.final.csv` or `EconomicSector.final.xlsx`
- `IPC.xlsx`
- `old_tc*.csv`, `old_*.xls`, `FinancialSystemBolivia.xlsx`

Then install R 4.2 or newer, Quarto, and the packages listed in `requirements.txt`, and run:

```r
source("src/99_run_all.R")
```

or:

```r
source("replication/run_project.R")
```

## Dashboard

The current reconstructed dashboard is static and can be opened directly:

```text
dashboard/index.html
```

The Shiny scaffold remains available for an R-enabled environment:

```r
shiny::runApp("dashboard")
```

## Reproducibility Statement

The reconstructed outputs use real official public data. `CreditType.reconstructed` and `EconomicSector.reconstructed` are annual official equivalents, not the exact lost monthly product-credit and sector-credit panels. This limitation is documented in `docs/DATA_RECONSTRUCTION_LOG.md` and `data/metadata/source_download_status.csv`.
