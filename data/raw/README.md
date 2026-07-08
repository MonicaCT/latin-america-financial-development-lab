# Raw Data

Place original, non-edited source files here.

The current GitHub repository does not version the raw financial datasets used
by the legacy scripts. The reproducible pipeline searches for these expected
inputs:

- `PanelCompleto.xlsx` or `PanelCompleto.final.xlsx`
- `CreditType_panel.xlsx` or `CreditType.final.xlsx`
- `EconomicSector_panel.xlsx` or `EconomicSector.final.xlsx`
- CSV equivalents of the same files

The legacy scripts also reference external folders such as `Data/Raw`,
`Data/Backup`, `Data/Clean`, `Data.ES/Raw.ES`, `Data.ES/Clean.ES`, and absolute
paths under `/Final_*`.
