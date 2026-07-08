start_time <- Sys.time()

source(file.path("src", "00_setup.R"))
source(path("src", "00_data_recovery_audit.R"))
source(path("src", "01_load_data.R"))
source(path("src", "02_clean_data.R"))
source(path("src", "03_validate_panel.R"))
source(path("src", "04_descriptive_analysis.R"))
source(path("src", "05_figures_editorial.R"))
source(path("src", "06_econometric_models.R"))
source(path("src", "07_robustness_checks.R"))
source(path("src", "08_country_profiles.R"))
source(path("src", "09_sector_profiles.R"))
source(path("src", "10_dashboard_data.R"))
source(path("src", "11_advanced_visualizations.R"))
source(path("src", "12_export_tables.R"))
source(path("src", "13_reports_and_pages.R"))

session_file <- path("replication", "session_info.txt")
write_text_safe(c(
  "FinancialData replication run",
  paste("Started:", format(start_time, "%Y-%m-%d %H:%M:%S")),
  paste("Finished:", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
  "",
  capture.output(sessionInfo())
), session_file)

append_status(status_row("99_run_all", "complete", paste("Runtime seconds:", round(difftime(Sys.time(), start_time, units = "secs"), 2))))
message("Full FinancialData pipeline complete")
