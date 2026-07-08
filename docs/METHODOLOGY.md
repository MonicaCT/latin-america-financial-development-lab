# Methodology

## Research Design

The project studies how credit composition and productive-sector financing evolve
across Latin America. It combines descriptive panel analytics, sectoral
concentration metrics, country rankings, Bolivia-centered comparison, clustering,
and panel econometric specifications when the data support estimation.

## Unit of Analysis

The intended unit is country-period, with period inferred from the data. The
legacy scripts use date variables and monthly updates. Annual indicators are
constructed from monthly data using annual means unless a source-specific stock
definition is documented.

## Core Data Products

- `CreditType`: credit disaggregated by product or credit type.
- `EconomicSector`: credit disaggregated by productive economic sector.
- `PanelCompleto`: merged country-period panel.

## Indicator Construction

The pipeline attempts to construct:

- `total_credit`: total outstanding credit.
- `productive_credit`: credit allocated to productive activity.
- `non_productive_credit`: total credit minus productive credit.
- `productive_credit_share`: productive credit divided by total credit.
- `sector_credit_share`: sector credit divided by observed sector total.
- `credit_growth_yoy`: year-over-year total credit growth.
- `real_credit_index`: base-100 real credit index when deflated variables exist.
- `credit_per_country_index`: base-100 country-specific credit index.
- `sector_concentration_hhi`: sum of squared sector shares.
- `sector_diversification_index`: one minus HHI.
- `credit_volatility`: country-level volatility of credit growth.
- `rolling_growth_3y`: three-year rolling average credit growth.
- `rolling_volatility_3y`: three-year rolling volatility.
- `country_rank_productive_credit`: ranking by productive credit.
- `country_rank_diversification`: ranking by diversification.
- `pre_post_crisis_dummy`: crisis-period marker for 2008-2009.
- `covid_period_dummy`: marker for 2020-2021.
- `post_covid_dummy`: marker for 2022 onward.

When the required source variables are unavailable, the script records the
indicator as unavailable.

## Descriptive Evidence

The descriptive workflow produces panel coverage, variable dictionary, missing
value audit, descriptive statistics, country rankings, and editorial figures.

## Econometric Strategy

The preferred dependent variable is:

```text
productive_credit_share_it
```

Candidate explanatory variables:

- `sector_concentration_hhi`
- `credit_growth_yoy`
- `credit_volatility`
- country fixed effects
- year fixed effects
- lagged credit indicators

Minimum planned specifications:

- Pooled OLS.
- Country fixed effects.
- Two-way country and year fixed effects.
- Random effects.
- Hausman test.
- Country-clustered robust errors.
- Driscoll-Kraay standard errors when panel structure allows.
- Lagged specifications.

If an adequate dependent variable or panel structure is missing, the model script
creates status outputs rather than numerical claims.

## Robustness Strategy

The robustness script is prepared for outlier exclusion, winsorization at the 1st
and 99th percentiles, crisis-year exclusion, pre/post COVID comparisons, Bolivia
versus rest-of-region comparisons, fixed-effect alternatives, lagged variables,
and alternative standard errors.

## Clustering Strategy

Country typologies are planned using productive credit share, sectoral
concentration, diversification, credit growth, and volatility. Methods include
k-means clustering, hierarchical clustering, and PCA when sufficient complete
observations exist.

The central comparative question is: Which countries share Bolivia's financial
development profile?

## Limitations

The current repository lacks versioned raw or cleaned data. As a result, no
substantive empirical finding should be read from placeholder outputs. All
results must be regenerated after the source data are restored.
