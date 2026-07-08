if (!exists("ROOT")) source(file.path("src", "00_setup.R"))
if (!exists("financial_panel")) source(path("src", "04_descriptive_analysis.R"))

dashboard_panel <- financial_panel
if (nrow(dashboard_panel) == 0) {
  dashboard_panel <- data.frame(
    country = character(),
    year = integer(),
    total_credit = numeric(),
    productive_credit = numeric(),
    productive_credit_share = numeric(),
    sector_diversification_index = numeric(),
    credit_growth_yoy = numeric(),
    credit_volatility = numeric(),
    data_status = character(),
    stringsAsFactors = FALSE
  )
}

kpi <- data.frame(
  metric = c(
    "countries",
    "years",
    "observations",
    "total_credit",
    "productive_credit",
    "average_productive_share",
    "most_financed_sector",
    "most_diversified_country"
  ),
  value = c(
    if (nrow(financial_panel) > 0) length(unique(financial_panel$country)) else 0,
    if (nrow(financial_panel) > 0) length(unique(financial_panel$year)) else 0,
    nrow(financial_panel),
    if ("total_credit" %in% names(financial_panel)) sum(financial_panel$total_credit, na.rm = TRUE) else NA,
    if ("productive_credit" %in% names(financial_panel)) sum(financial_panel$productive_credit, na.rm = TRUE) else NA,
    if ("productive_credit_share" %in% names(financial_panel)) mean(financial_panel$productive_credit_share, na.rm = TRUE) else NA,
    "not available",
    if (nrow(financial_panel) > 0 && "sector_diversification_index" %in% names(financial_panel)) {
      financial_panel$country[which.max(financial_panel$sector_diversification_index)]
    } else {
      "not available"
    }
  ),
  stringsAsFactors = FALSE
)

write_csv_safe(dashboard_panel, path("outputs", "dashboard", "dashboard_panel.csv"))
write_csv_safe(kpi, path("outputs", "dashboard", "dashboard_kpi.csv"))
append_status(status_row("10_dashboard_data", if (nrow(financial_panel) > 0) "complete_with_data" else "complete_without_data", paste("Dashboard rows:", nrow(dashboard_panel))))
message("10_dashboard_data complete")
