if (!exists("ROOT")) source(file.path("src", "00_setup.R"))

data_ext <- c("csv", "xlsx", "xls", "rds", "rdata", "parquet", "feather", "fst", "txt", "dta", "zip", "sav")

all_files <- list.files(ROOT, recursive = TRUE, full.names = TRUE, all.files = TRUE, no.. = TRUE)
all_files <- all_files[!grepl("/\\.git/", normalizePath(all_files, winslash = "/", mustWork = FALSE))]
file_inventory <- data.frame(
  relative_path = sub(paste0("^", gsub("\\\\", "/", ROOT), "/?"), "", normalizePath(all_files, winslash = "/", mustWork = FALSE)),
  extension = tolower(tools::file_ext(all_files)),
  bytes = ifelse(file.exists(all_files), file.info(all_files)$size, NA_real_),
  likely_data = tolower(tools::file_ext(all_files)) %in% data_ext,
  stringsAsFactors = FALSE
)

write_csv_safe(file_inventory, path("data", "metadata", "exhaustive_file_inventory.csv"))

expected_sources <- data.frame(
  dataset = c("PanelCompleto", "CreditType", "EconomicSector", "IPC", "Country backups"),
  patterns = c(
    "PanelCompleto.final.xlsx; PanelCompleto.final.csv; PanelCompleto_panel.xlsx",
    "CreditType.final.xlsx; CreditType.final.csv; CreditType_panel.xlsx",
    "EconomicSector.final.xlsx; EconomicSector.final.csv; EconomicSector_panel.xlsx",
    "IPC.xlsx; IPC.csv",
    "old_tc*.csv; old_*.xls; FinancialSystemBolivia.xlsx"
  ),
  found = "no",
  reconstruction = c(
    "Requires CreditType.final and EconomicSector.final or restored legacy folders.",
    "Requires restored raw/backup files or successful source downloads.",
    "Requires EconomicSector_panel and IPC files or restored Data.ES folders.",
    "Required for deflated indices.",
    "No backup/raw folder is committed."
  ),
  stringsAsFactors = FALSE
)

write_csv_safe(expected_sources, path("outputs", "tables", "data_recovery_status.csv"))

write_text_safe(c(
  "# Data Recovery Audit",
  "",
  "The automated audit searches current repository files for common analytical data formats.",
  "At the public repository state, no original analytical panels are available.",
  "",
  "See `data/metadata/exhaustive_file_inventory.csv` and `outputs/tables/data_recovery_status.csv`."
), path("docs", "DATA_RECOVERY_AUDIT.md"))

append_status(status_row("00_data_recovery_audit", "complete", paste("Files inventoried:", nrow(file_inventory))))
message("00_data_recovery_audit complete")
