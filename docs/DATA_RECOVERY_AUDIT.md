# Data Recovery Audit

Last updated: 2026-07-08


> **Reconstruction update:** This audit remains the evidence that the exact legacy processed files were absent from the repository and Git history. After this audit, a public-data reconstruction was completed. See `docs/DATA_RECONSTRUCTION_LOG.md`, `data/processed/PanelCompleto.reconstructed.csv`, `data/processed/CreditType.reconstructed.csv`, and `data/processed/EconomicSector.reconstructed.csv`.
## Bottom Line

An exhaustive repository and Git-history audit found no recoverable analytical data files in `latin-america-financial-development-lab`. The repository contains legacy R scripts, TeX files, PDF procedure notes, and generated diagnostic outputs, but no committed raw or cleaned panels such as `CreditType.final`, `EconomicSector.final`, `PanelCompleto.final`, `IPC`, or country backup files.

## Evidence Reviewed

1. Current repository tree, including hidden files and generated outputs.
2. Git history across all commits, branches, and tags.
3. Script I/O references in all legacy and new R scripts.
4. Targeted workspace search under `C:\Users\Asus\Documents\Github` for expected dataset names.
5. Procedure PDFs describing the legacy construction process.

## Current Repository Findings

The only current `.csv` files are generated diagnostics and status outputs. No original `.xlsx`, `.xls`, `.rds`, `.RData`, `.parquet`, `.feather`, `.fst`, `.dta`, `.zip`, or country backup files were found in the repository.

## Git History Findings

The repository history contains three commits:

- Initial README commit.
- Upload of legacy scripts, TeX files, and PDF procedure documents.
- README portfolio taxonomy update.

No historical commit contains raw or cleaned data files.

## Workspace Search Findings

A targeted search for `CreditType`, `EconomicSector`, `PanelCompleto`, `IPC`, `old_tc`, `FinancialSystemBolivia`, `Economic Sector`, and `Credit Type` did not find recoverable analytical datasets outside the repository. Matches were scripts, TeX/PDF files, or unrelated PortableGit documentation.

## Required Data Files

The minimum files needed for full empirical reconstruction are:

- `CreditType.final.csv` or `CreditType.final.xlsx`
- `EconomicSector.final.csv` or `EconomicSector.final.xlsx`
- `PanelCompleto.final.csv` or `PanelCompleto.final.xlsx`
- `IPC.csv` or `IPC.xlsx`
- country backup files such as `old_tcargentina.csv`, `old_tcbolivia.csv`, and related raw Excel/PDF inputs

## Reconstruction Potential

The legacy scripts contain enough procedural logic to reconstruct the datasets if the source files are restored or if web downloads are rerun in a complete R environment. However, several countries require manual downloads or source-specific transformations, so full reconstruction is not guaranteed to be automatic without source access and package availability.

## Decision

No substantive empirical results were generated because the required source data are absent. All current tables, figures, dashboards, and reports are diagnostic or status outputs, not research findings.

## Artifacts Created

- `data/metadata/exhaustive_file_inventory.csv`
- `data/metadata/git_history_inventory.csv`
- `data/metadata/script_io_inventory.csv`
- `outputs/tables/data_recovery_status.csv`
- `outputs/tables/advanced_figure_status.csv`
- `outputs/figures/data_recovery_audit.png`
- `outputs/figures/data_recovery_audit.pdf`


