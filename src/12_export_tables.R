if (!exists("ROOT")) source(file.path("src", "00_setup.R"))

dir_create("outputs", "tables", "html")
dir_create("outputs", "tables", "tex")
dir_create("outputs", "tables", "excel")

html_escape <- function(x) {
  x <- as.character(x)
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  x
}

tex_escape <- function(x) {
  x <- as.character(x)
  x <- gsub("\\\\", "\\\\textbackslash{}", x)
  x <- gsub("&", "\\\\&", x, fixed = TRUE)
  x <- gsub("%", "\\\\%", x, fixed = TRUE)
  x <- gsub("_", "\\\\_", x, fixed = TRUE)
  x
}

write_html_table <- function(df, file, title) {
  rows <- if (nrow(df) > 0) apply(df, 1, function(r) paste0("<tr>", paste0("<td>", html_escape(r), "</td>", collapse = ""), "</tr>")) else character()
  head <- paste0("<tr>", paste0("<th>", html_escape(names(df)), "</th>", collapse = ""), "</tr>")
  html <- c(
    "<!doctype html><html><head><meta charset='utf-8'>",
    "<style>body{font-family:Arial,sans-serif;margin:32px;color:#1f2933}table{border-collapse:collapse;width:100%}th{background:#1f2933;color:white;text-align:left}td,th{border:1px solid #e5e7eb;padding:6px 8px;font-size:12px}h1{border-top:4px solid #bb1e10;padding-top:16px}</style>",
    "</head><body>", paste0("<h1>", html_escape(title), "</h1>"), "<table>", head, rows, "</table></body></html>"
  )
  write_text_safe(html, file)
}

write_tex_table <- function(df, file) {
  if (ncol(df) == 0) {
    write_text_safe("% Empty table", file)
    return(invisible(file))
  }
  lines <- c(paste0("\\begin{tabular}{", paste(rep("l", ncol(df)), collapse = ""), "}"), "\\hline")
  lines <- c(lines, paste0(paste(tex_escape(names(df)), collapse = " & "), " ", "\\\\", " ", "\\hline"))
  if (nrow(df) > 0) for (i in seq_len(nrow(df))) lines <- c(lines, paste0(paste(tex_escape(df[i, ]), collapse = " & "), " ", "\\\\"))
  lines <- c(lines, "\\hline", "\\end{tabular}")
  write_text_safe(lines, file)
}

write_excel_table <- function(df, file) {
  if (has_pkg("openxlsx")) {
    openxlsx::write.xlsx(df, file, overwrite = TRUE)
  } else if (has_pkg("writexl")) {
    writexl::write_xlsx(df, file)
  } else {
    utils::write.csv(df, sub("\\.xlsx$", ".csv", file), row.names = FALSE, na = "")
  }
  invisible(file)
}

csv_files <- list.files(path("outputs", "tables"), pattern = "\\.csv$", full.names = TRUE)
for (f in csv_files) {
  df <- tryCatch(utils::read.csv(f, check.names = FALSE), error = function(e) data.frame(error = conditionMessage(e)))
  base <- tools::file_path_sans_ext(basename(f))
  write_html_table(df, path("outputs", "tables", "html", paste0(base, ".html")), base)
  write_tex_table(df, path("outputs", "tables", "tex", paste0(base, ".tex")))
  write_excel_table(df, path("outputs", "tables", "excel", paste0(base, ".xlsx")))
}

append_status(status_row("12_export_tables", "complete", paste("Tables exported:", length(csv_files))))
message("12_export_tables complete")

