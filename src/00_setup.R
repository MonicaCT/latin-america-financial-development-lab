options(stringsAsFactors = FALSE)

project_root <- function() {
  wd <- normalizePath(getwd(), winslash = "/", mustWork = FALSE)
  if (file.exists(file.path(wd, "README.md")) && dir.exists(file.path(wd, "src"))) {
    return(wd)
  }
  parent <- normalizePath(file.path(wd, ".."), winslash = "/", mustWork = FALSE)
  if (file.exists(file.path(parent, "README.md")) && dir.exists(file.path(parent, "src"))) {
    return(parent)
  }
  stop("Project root not found. Run from the repository root or src/ folder.")
}

ROOT <- project_root()

path <- function(...) file.path(ROOT, ...)

dir_create <- function(...) {
  x <- path(...)
  if (!dir.exists(x)) dir.create(x, recursive = TRUE, showWarnings = FALSE)
  invisible(x)
}

required_dirs <- list(
  c("docs"),
  c("data", "raw"),
  c("data", "processed"),
  c("data", "metadata"),
  c("src"),
  c("outputs", "figures"),
  c("outputs", "tables"),
  c("outputs", "maps"),
  c("outputs", "models"),
  c("outputs", "dashboard"),
  c("report"),
  c("dashboard"),
  c("dashboard", "www"),
  c("replication")
)
invisible(lapply(required_dirs, function(x) do.call(dir_create, as.list(x))))

has_pkg <- function(pkg) requireNamespace(pkg, quietly = TRUE)

load_pkg <- function(pkg) {
  ok <- has_pkg(pkg)
  if (ok) suppressPackageStartupMessages(library(pkg, character.only = TRUE))
  ok
}

write_csv_safe <- function(x, file) {
  dir.create(dirname(file), recursive = TRUE, showWarnings = FALSE)
  utils::write.csv(x, file, row.names = FALSE, na = "")
  invisible(file)
}

write_text_safe <- function(x, file) {
  dir.create(dirname(file), recursive = TRUE, showWarnings = FALSE)
  writeLines(x, con = file, useBytes = TRUE)
  invisible(file)
}

clean_name <- function(x) {
  x <- gsub("([a-z0-9])([A-Z])", "\\1_\\2", x)
  x <- gsub("[^A-Za-z0-9]+", "_", x)
  x <- gsub("_+", "_", x)
  x <- gsub("^_|_$", "", x)
  tolower(x)
}

clean_names_df <- function(df) {
  names(df) <- clean_name(names(df))
  df
}

standardize_country <- function(x) {
  x <- trimws(as.character(x))
  recode <- c(
    "Brasil" = "Brazil",
    "Republica Dominicana" = "Dominican Republic",
    "Rep Dominicana" = "Dominican Republic",
    "DominicanRepublic" = "Dominican Republic",
    "CostaRica" = "Costa Rica",
    "ElSalvador" = "El Salvador",
    "Mexico" = "Mexico",
    "Peru" = "Peru"
  )
  out <- ifelse(x %in% names(recode), unname(recode[x]), x)
  out
}

parse_year_safe <- function(df) {
  if ("year" %in% names(df)) {
    suppressWarnings(as.integer(df$year))
  } else if ("date" %in% names(df)) {
    suppressWarnings(as.integer(format(as.Date(df$date), "%Y")))
  } else {
    rep(NA_integer_, nrow(df))
  }
}

numeric_safe <- function(x) {
  if (is.numeric(x)) return(x)
  x <- gsub(",", "", as.character(x))
  x <- gsub("[^0-9.\\-]", "", x)
  suppressWarnings(as.numeric(x))
}

first_existing <- function(df, candidates) {
  idx <- candidates[candidates %in% names(df)]
  if (length(idx) == 0) return(rep(NA_real_, nrow(df)))
  numeric_safe(df[[idx[1]]])
}

read_any_table <- function(file) {
  ext <- tolower(tools::file_ext(file))
  if (ext %in% c("csv", "txt")) {
    return(utils::read.csv(file, check.names = FALSE))
  }
  if (ext %in% c("xlsx", "xls")) {
    if (!has_pkg("readxl")) {
      stop("Package readxl is required to read Excel files: ", basename(file))
    }
    return(readxl::read_excel(file))
  }
  stop("Unsupported file extension: ", ext)
}

empty_panel <- function() {
  data.frame(
    country = character(),
    date = as.Date(character()),
    year = integer(),
    stringsAsFactors = FALSE
  )
}

expected_countries <- c(
  "Argentina", "Bolivia", "Brazil", "Chile", "Colombia", "Costa Rica",
  "Dominican Republic", "Ecuador", "El Salvador", "Guatemala", "Honduras",
  "Mexico", "Nicaragua", "Panama", "Paraguay", "Peru", "Venezuela"
)

sector_clean_vars <- c(
  "agricultural_credit", "commerce_credit", "industry_credit",
  "remaining_credit", "individuals_credit"
)

status_row <- function(step, status, message) {
  data.frame(
    step = step,
    status = status,
    message = message,
    timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
    stringsAsFactors = FALSE
  )
}

append_status <- function(row) {
  file <- path("outputs", "tables", "pipeline_status.csv")
  old <- if (file.exists(file)) utils::read.csv(file) else data.frame()
  write_csv_safe(rbind(old, row), file)
}

safe_source <- function(file) {
  source(path("src", file), local = FALSE)
}

message("Financial development setup complete: ", ROOT)
