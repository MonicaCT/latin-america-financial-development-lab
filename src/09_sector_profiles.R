if (!exists("ROOT")) source(file.path("src", "00_setup.R"))
if (!exists("financial_panel")) source(path("src", "04_descriptive_analysis.R"))

sector_vars <- intersect(sector_clean_vars, names(financial_panel))

if (nrow(financial_panel) == 0 || length(sector_vars) == 0) {
  sector_profiles <- data.frame(
    sector = c("agricultural", "commerce", "industry", "remaining", "individuals"),
    status = "not available",
    profile = "Sector credit data are not available in the repository.",
    stringsAsFactors = FALSE
  )
} else {
  sector_profiles <- do.call(rbind, lapply(sector_vars, function(v) {
    x <- numeric_safe(financial_panel[[v]])
    data.frame(
      sector = gsub("_credit", "", v),
      observations = sum(!is.na(x)),
      mean_credit = mean(x, na.rm = TRUE),
      max_credit = max(x, na.rm = TRUE),
      status = "available",
      profile = paste(gsub("_credit", "", v), "has", sum(!is.na(x)), "observations in the analysis panel."),
      stringsAsFactors = FALSE
    )
  }))
}

write_csv_safe(sector_profiles, path("outputs", "tables", "sector_profiles.csv"))
write_text_safe(c("# Sector Profiles", "", paste("- ", sector_profiles$profile, collapse = "\n")), path("outputs", "tables", "sector_profiles.md"))
append_status(status_row("09_sector_profiles", if (length(sector_vars) > 0) "complete_with_data" else "complete_without_data", paste("Sector profiles:", nrow(sector_profiles))))
message("09_sector_profiles complete")
