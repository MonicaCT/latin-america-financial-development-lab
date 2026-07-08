if (!exists("ROOT")) source(file.path("src", "00_setup.R"))
if (!exists("loaded_data")) source(path("src", "01_load_data.R"))

normalize_panel <- function(df, dataset_name) {
  if (nrow(df) == 0) return(empty_panel())
  df <- clean_names_df(as.data.frame(df))

  country_col <- intersect(c("country", "pais"), names(df))
  if (length(country_col) > 0) {
    df$country <- standardize_country(df[[country_col[1]]])
  } else {
    df$country <- NA_character_
  }

  date_col <- intersect(c("date", "fecha", "period", "periodo"), names(df))
  if (length(date_col) > 0) {
    df$date <- suppressWarnings(as.Date(df[[date_col[1]]]))
  } else if ("year" %in% names(df)) {
    df$date <- suppressWarnings(as.Date(paste0(as.integer(df$year), "-12-31")))
  } else {
    df$date <- as.Date(NA)
  }
  df$year <- parse_year_safe(df)
  df$source_dataset <- dataset_name
  df
}

credit <- normalize_panel(loaded_data$credit_type$data, "credit_type")
sector <- normalize_panel(loaded_data$economic_sector$data, "economic_sector")
panel <- normalize_panel(loaded_data$panel_completo$data, "panel_completo")

rename_if_present <- function(df, from, to) {
  idx <- from[from %in% names(df)]
  if (length(idx) > 0 && !(to %in% names(df))) names(df)[names(df) == idx[1]] <- to
  df
}

standardize_credit_vars <- function(df) {
  if (nrow(df) == 0) return(df)
  mappings <- list(
    total_credit_alt = c("total", "total_credit", "t_credit", "tcredit"),
    commercial_credit = c("commercial_credit", "comercial", "commercialcredit"),
    consumer_credit = c("consumer_credit", "consumercredit", "consumo"),
    credit_card = c("credit_card", "creditcard"),
    mortgage = c("mortgage", "hipotecaria", "hipo"),
    microcredit = c("microcredit", "microcredito"),
    smes = c("smes", "pymes"),
    business_credit = c("business_credit", "businesscredit", "totalem"),
    leasing = c("leasing"),
    government_credit = c("government", "government_credit"),
    personal_credit = c("personal_credit", "personalcredit")
  )
  for (to in names(mappings)) df <- rename_if_present(df, mappings[[to]], to)
  df
}

standardize_sector_vars <- function(df) {
  if (nrow(df) == 0) return(df)
  mappings <- list(
    total_credit = c("t_credit", "total_credit", "total"),
    productive_credit = c("t_productive", "productive_credit"),
    industry_credit = c("industry", "industrial", "industry_credit"),
    agricultural_credit = c("agricultural", "agricola", "agricultural_credit"),
    commerce_credit = c("commerce", "commerce_credit"),
    individuals_credit = c("individuals", "individuals_credit"),
    remaining_credit = c("remaining", "remaining_credit")
  )
  for (to in names(mappings)) df <- rename_if_present(df, mappings[[to]], to)
  df
}

credit <- standardize_credit_vars(credit)
sector <- standardize_sector_vars(sector)
panel <- standardize_credit_vars(standardize_sector_vars(panel))

make_analysis_panel <- function(panel, credit, sector) {
  if (nrow(panel) > 0) return(panel)
  keys <- unique(rbind(
    credit[, intersect(c("country", "date", "year"), names(credit)), drop = FALSE],
    sector[, intersect(c("country", "date", "year"), names(sector)), drop = FALSE]
  ))
  if (nrow(keys) == 0) return(empty_panel())
  merged <- keys
  if (nrow(credit) > 0) merged <- merge(merged, credit, by = intersect(c("country", "date", "year"), names(credit)), all.x = TRUE)
  if (nrow(sector) > 0) merged <- merge(merged, sector, by = intersect(c("country", "date", "year"), names(sector)), all.x = TRUE, suffixes = c("", "_sector"))
  merged
}

analysis_panel <- make_analysis_panel(panel, credit, sector)

write_csv_safe(credit, path("data", "processed", "credit_type_panel_clean.csv"))
write_csv_safe(sector, path("data", "processed", "economic_sector_panel_clean.csv"))
write_csv_safe(panel, path("data", "processed", "panel_completo_clean.csv"))
write_csv_safe(analysis_panel, path("data", "processed", "financial_development_panel_base.csv"))

append_status(status_row(
  "02_clean_data",
  if (nrow(analysis_panel) > 0) "complete_with_data" else "complete_without_data",
  paste("Analysis panel rows:", nrow(analysis_panel), "columns:", ncol(analysis_panel))
))

message("02_clean_data complete")
