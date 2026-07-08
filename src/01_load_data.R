if (!exists("ROOT")) source(file.path("src", "00_setup.R"))

candidate_roots <- c(
  path("data", "raw"),
  path("Data"),
  path("Data", "Clean"),
  path("Data", "Raw"),
  path("Data", "Backup"),
  path("Data.ES"),
  path("Data.ES", "Clean.ES"),
  path("Data.ES", "Raw.ES"),
  ROOT
)
candidate_roots <- candidate_roots[dir.exists(candidate_roots)]

find_candidates <- function(patterns) {
  files <- unlist(lapply(candidate_roots, function(root) {
    list.files(root, recursive = TRUE, full.names = TRUE, ignore.case = TRUE)
  }), use.names = FALSE)
  files <- unique(files[file.exists(files)])
  keep <- Reduce(`|`, lapply(patterns, function(p) grepl(p, basename(files), ignore.case = TRUE)))
  files[keep]
}

dataset_patterns <- list(
  panel_completo = c("^PanelCompleto.*\\.(csv|xlsx|xls)$"),
  credit_type = c("^CreditType.*\\.(csv|xlsx|xls)$", "^CreditType_panel.*\\.(csv|xlsx|xls)$"),
  economic_sector = c("^EconomicSector.*\\.(csv|xlsx|xls)$", "^EconomicSector_panel.*\\.(csv|xlsx|xls)$"),
  ipc = c("^IPC.*\\.(csv|xlsx|xls)$")
)

load_one_dataset <- function(name, patterns) {
  files <- find_candidates(patterns)
  if (length(files) == 0) {
    return(list(
      name = name,
      file = NA_character_,
      data = empty_panel(),
      status = "missing",
      message = paste("No source file found for", name)
    ))
  }
  preferred <- files[order(nchar(files))][1]
  out <- tryCatch({
    df <- as.data.frame(read_any_table(preferred))
    list(
      name = name,
      file = preferred,
      data = df,
      status = "loaded",
      message = paste("Loaded", nrow(df), "rows and", ncol(df), "columns")
    )
  }, error = function(e) {
    list(
      name = name,
      file = preferred,
      data = empty_panel(),
      status = "failed",
      message = conditionMessage(e)
    )
  })
  out
}

loaded_data <- lapply(names(dataset_patterns), function(nm) {
  load_one_dataset(nm, dataset_patterns[[nm]])
})
names(loaded_data) <- names(dataset_patterns)

source_inventory <- do.call(rbind, lapply(loaded_data, function(x) {
  data.frame(
    dataset = x$name,
    file = ifelse(is.na(x$file), "", normalizePath(x$file, winslash = "/", mustWork = FALSE)),
    status = x$status,
    rows = nrow(x$data),
    columns = ncol(x$data),
    message = x$message,
    stringsAsFactors = FALSE
  )
}))

legacy_files <- data.frame(
  file = list.files(ROOT, pattern = "\\.(R|tex|pdf|md)$", ignore.case = TRUE),
  role = c(
    "legacy economic-sector cleaning",
    "legacy panel merge",
    "legacy data download",
    "legacy credit-type cleaning",
    "legacy economic-sector country figures",
    "legacy credit-type country figures",
    "legacy economic-sector sector figures",
    "legacy productive-credit comparison",
    "legacy credit-type figures",
    "sector country TeX output",
    "sector country deflated TeX output",
    "sector TeX output",
    "productive credit TeX output",
    "credit-type procedure PDF",
    "economic-sector procedure PDF",
    "panel merge procedure PDF",
    "R code explanation PDF",
    "project README"
  )[seq_along(list.files(ROOT, pattern = "\\.(R|tex|pdf|md)$", ignore.case = TRUE))],
  stringsAsFactors = FALSE
)

write_csv_safe(source_inventory, path("data", "metadata", "source_inventory.csv"))
write_csv_safe(source_inventory, path("data", "metadata", "load_status.csv"))
write_csv_safe(legacy_files, path("data", "metadata", "legacy_file_inventory.csv"))

append_status(status_row(
  "01_load_data",
  if (any(source_inventory$status == "loaded")) "complete_with_data" else "complete_without_data",
  paste(source_inventory$dataset, source_inventory$status, collapse = "; ")
))

message("01_load_data complete")
