if (!exists("ROOT")) source(file.path("src", "00_setup.R"))
if (!exists("analysis_panel")) source(path("src", "02_clean_data.R"))

panel_coverage <- function(df) {
  if (nrow(df) == 0 || !"country" %in% names(df)) {
    return(data.frame(
      country = expected_countries,
      first_year = NA_integer_,
      last_year = NA_integer_,
      observations = 0L,
      variables_available = "",
      missing_percent = NA_real_,
      data_status = "source data not versioned",
      stringsAsFactors = FALSE
    ))
  }
  vars <- setdiff(names(df), c("country", "date", "year", "source_dataset"))
  do.call(rbind, lapply(split(df, df$country), function(x) {
    miss <- if (length(vars) == 0) NA_real_ else mean(is.na(x[, vars, drop = FALSE])) * 100
    data.frame(
      country = unique(x$country)[1],
      first_year = suppressWarnings(min(x$year, na.rm = TRUE)),
      last_year = suppressWarnings(max(x$year, na.rm = TRUE)),
      observations = nrow(x),
      variables_available = paste(vars[colSums(!is.na(x[, vars, drop = FALSE])) > 0], collapse = "; "),
      missing_percent = miss,
      data_status = "loaded",
      stringsAsFactors = FALSE
    )
  }))
}

missing_values <- function(df) {
  if (nrow(df) == 0) {
    return(data.frame(
      variable = character(),
      total_observations = integer(),
      missing = integer(),
      missing_percent = numeric(),
      countries_most_affected = character(),
      stringsAsFactors = FALSE
    ))
  }
  do.call(rbind, lapply(names(df), function(v) {
    miss_by_country <- if ("country" %in% names(df)) {
      tapply(is.na(df[[v]]), df$country, mean)
    } else {
      numeric()
    }
    affected <- names(sort(miss_by_country, decreasing = TRUE))[1:min(5, length(miss_by_country))]
    data.frame(
      variable = v,
      total_observations = length(df[[v]]),
      missing = sum(is.na(df[[v]])),
      missing_percent = mean(is.na(df[[v]])) * 100,
      countries_most_affected = paste(affected, collapse = "; "),
      stringsAsFactors = FALSE
    )
  }))
}

variable_dictionary <- data.frame(
  original_name = c("Country", "Date", "T.credit", "T.productive", "Agricultural", "Commerce", "Industry", "Remaining", "Total"),
  clean_name = c("country", "date", "total_credit", "productive_credit", "agricultural_credit", "commerce_credit", "industry_credit", "remaining_credit", "total_credit_alt"),
  definition = c(
    "Country name",
    "Observation date",
    "Total outstanding credit",
    "Total productive credit",
    "Credit to agriculture",
    "Credit to commerce",
    "Credit to industry",
    "Credit to remaining sectors",
    "Total credit in credit-type panel"
  ),
  unit = "source units",
  source = c("all panels", "all panels", rep("economic sector panel", 6), "credit type panel"),
  transformation = c("standardized spelling", "parsed date", rep("numeric cleaning", 7)),
  analytical_use = c("panel id", "time id", "scale and growth", "main outcome numerator", rep("sector shares", 4), "cross-check total"),
  stringsAsFactors = FALSE
)

coverage_table <- panel_coverage(analysis_panel)
missing_table <- missing_values(analysis_panel)

write_csv_safe(coverage_table, path("outputs", "tables", "panel_coverage.csv"))
write_csv_safe(variable_dictionary, path("outputs", "tables", "variable_dictionary.csv"))
write_csv_safe(missing_table, path("outputs", "tables", "missing_values.csv"))
write_csv_safe(coverage_table, path("data", "metadata", "qc_country_coverage.csv"))
write_csv_safe(missing_table, path("data", "metadata", "qc_missing_values.csv"))

validation_note <- c(
  "# Validation Report",
  "",
  paste("Rows in analysis panel:", nrow(analysis_panel)),
  paste("Columns in analysis panel:", ncol(analysis_panel)),
  "",
  if (nrow(analysis_panel) == 0) {
    "No source data were available. Coverage and missing-value outputs are structural status tables, not empirical results."
  } else {
    "Source data were loaded. Review CSV outputs for coverage, variable availability, and missingness."
  }
)
write_text_safe(validation_note, path("data", "metadata", "validation_report.md"))

append_status(status_row(
  "03_validate_panel",
  if (nrow(analysis_panel) > 0) "complete_with_data" else "complete_without_data",
  paste("Coverage rows:", nrow(coverage_table), "missing-value rows:", nrow(missing_table))
))

message("03_validate_panel complete")
