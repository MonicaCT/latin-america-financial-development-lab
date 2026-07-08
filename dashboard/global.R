dashboard_root <- normalizePath(file.path(getwd()), winslash = "/", mustWork = FALSE)
if (basename(dashboard_root) == "dashboard") dashboard_root <- normalizePath(file.path(dashboard_root, ".."), winslash = "/", mustWork = FALSE)

read_dashboard_csv <- function(name) {
  file <- file.path(dashboard_root, "outputs", "dashboard", name)
  if (file.exists(file)) utils::read.csv(file, check.names = FALSE) else data.frame()
}

dashboard_panel <- read_dashboard_csv("dashboard_panel.csv")
dashboard_kpi <- read_dashboard_csv("dashboard_kpi.csv")

fmt_value <- function(x) {
  if (length(x) == 0 || is.na(x) || x == "") return("n/a")
  if (suppressWarnings(!is.na(as.numeric(x)))) return(format(round(as.numeric(x), 3), big.mark = ","))
  as.character(x)
}

kpi_value <- function(metric) {
  if (nrow(dashboard_kpi) == 0 || !(metric %in% dashboard_kpi$metric)) return("n/a")
  fmt_value(dashboard_kpi$value[dashboard_kpi$metric == metric][1])
}
