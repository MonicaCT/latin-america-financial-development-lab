# Variable Dictionary

This dictionary combines variables detected in the legacy scripts with the clean
names used by the new pipeline. Final definitions must be confirmed against
source metadata once the data files are restored.

| Original name | Clean name | Definition | Unit | Source | Transformation | Analytical use |
|---|---|---|---|---|---|---|
| `Country` | `country` | Country name. | Text | Legacy panels | Standardized spelling. | Panel identifier. |
| `Date` | `date` | Observation date. | Date | Legacy panels | Parsed as date. | Time identifier. |
| `year` | `year` | Calendar year. | Integer | Derived | Extracted from `date` when needed. | Annual aggregation and fixed effects. |
| `T.credit` | `total_credit` | Total outstanding credit. | Local currency or source units | Economic-sector panel | Cleaned numeric value. | Scale, growth, indices. |
| `T.productive` | `productive_credit` | Total productive credit. | Local currency or source units | Economic-sector panel | Cleaned numeric value. | Productive-credit share and rankings. |
| `Total` | `total_credit_alt` | Total credit in credit-type panel. | Local currency or source units | Credit-type panel | Cleaned numeric value. | Cross-check against `T.credit`. |
| `CommercialCredit` | `commercial_credit` | Commercial credit. | Local currency or source units | Credit-type panel | Cleaned numeric value. | Credit composition. |
| `ConsumerCredit` | `consumer_credit` | Consumer credit. | Local currency or source units | Credit-type panel | Cleaned numeric value. | Non-productive credit proxy when appropriate. |
| `CreditCard` | `credit_card` | Credit card lending. | Local currency or source units | Credit-type panel | Cleaned numeric value. | Household credit component. |
| `Mortgage` | `mortgage` | Mortgage or housing credit. | Local currency or source units | Credit-type panel | Cleaned numeric value. | Household/real-estate credit. |
| `Microcredit` | `microcredit` | Microcredit. | Local currency or source units | Credit-type panel | Cleaned numeric value. | Inclusion and productive finance proxy. |
| `SMEs` | `smes` | Small and medium enterprise credit. | Local currency or source units | Credit-type panel | Cleaned numeric value. | Productive finance proxy. |
| `BusinessCredit` | `business_credit` | Business credit. | Local currency or source units | Credit-type panel | Cleaned numeric value. | Productive finance proxy. |
| `Leasing` | `leasing` | Leasing credit. | Local currency or source units | Credit-type panel | Cleaned numeric value. | Productive asset finance. |
| `Government` | `government_credit` | Government credit. | Local currency or source units | Credit-type panel | Cleaned numeric value. | Credit allocation control. |
| `PersonalCredit` | `personal_credit` | Personal credit. | Local currency or source units | Credit-type panel | Cleaned numeric value. | Household credit component. |
| `Industry` | `industry_credit` | Credit to industry. | Local currency or source units | Economic-sector panel | Cleaned numeric value. | Sectoral allocation. |
| `Agricultural` | `agricultural_credit` | Credit to agriculture. | Local currency or source units | Economic-sector panel | Cleaned numeric value. | Sectoral allocation. |
| `Commerce` | `commerce_credit` | Credit to commerce. | Local currency or source units | Economic-sector panel | Cleaned numeric value. | Sectoral allocation. |
| `Individuals` | `individuals_credit` | Credit to individuals. | Local currency or source units | Economic-sector panel | Cleaned numeric value. | Non-productive credit proxy if documented. |
| `Remaining` | `remaining_credit` | Remaining sectors. | Local currency or source units | Economic-sector panel | Cleaned numeric value. | Residual sector allocation. |
| `iT.credit18` | `total_credit_index_2018` | Base-100 index, December 2018. | Index | Legacy script | `T.credit / T.credit_2018 * 100`. | Long-run growth figure. |
| `iT.credit18ipc` | `real_total_credit_index_2018` | Inflation-adjusted base-100 index. | Index | Legacy script and IPC | Deflated by IPC ratio. | Real credit dynamics. |
| Derived | `non_productive_credit` | Total minus productive credit. | Source units | Pipeline | Built only if both components exist. | Productive vs non-productive comparison. |
| Derived | `productive_credit_share` | Productive credit divided by total credit. | Ratio | Pipeline | `productive_credit / total_credit`. | Main dependent variable. |
| Derived | `sector_concentration_hhi` | Herfindahl-Hirschman index of sector shares. | Index 0-1 | Pipeline | Sum of squared sector shares. | Diversification and risk. |
| Derived | `sector_diversification_index` | Diversification measure. | Index 0-1 | Pipeline | `1 - HHI`. | Country ranking and clustering. |
| Derived | `credit_growth_yoy` | Year-over-year credit growth. | Rate | Pipeline | `total_credit / lag(total_credit) - 1`. | Macro-financial dynamics. |
| Derived | `credit_volatility` | Volatility of credit growth. | Standard deviation | Pipeline | Country-level SD of growth. | Risk indicator. |
