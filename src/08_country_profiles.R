if (!exists("ROOT")) source(file.path("src", "00_setup.R"))
if (!exists("financial_panel")) source(path("src", "04_descriptive_analysis.R"))

if (nrow(financial_panel) == 0 || !"country" %in% names(financial_panel)) {
  country_profiles <- data.frame(
    country = expected_countries,
    profile = "No source data available; restore cleaned panels and rerun pipeline.",
    stringsAsFactors = FALSE
  )
} else {
  latest <- do.call(rbind, lapply(split(financial_panel, financial_panel$country), function(x) x[which.max(ifelse(is.na(x$year), -Inf, x$year)), ]))
  country_profiles <- data.frame(
    country = latest$country,
    latest_year = latest$year,
    productive_credit_share = latest$productive_credit_share,
    sector_diversification_index = latest$sector_diversification_index,
    credit_volatility = latest$credit_volatility,
    profile = paste0(
      latest$country,
      " latest available profile: productive credit share = ",
      round(latest$productive_credit_share, 3),
      "; diversification = ",
      round(latest$sector_diversification_index, 3),
      "; volatility = ",
      round(latest$credit_volatility, 3),
      "."
    ),
    stringsAsFactors = FALSE
  )
}

write_csv_safe(country_profiles, path("outputs", "tables", "country_profiles.csv"))
write_text_safe(c("# Country Profiles", "", paste("- ", country_profiles$profile, collapse = "\n")), path("outputs", "tables", "country_profiles.md"))
append_status(status_row("08_country_profiles", if (nrow(financial_panel) > 0) "complete_with_data" else "complete_without_data", paste("Country profiles:", nrow(country_profiles))))
message("08_country_profiles complete")
