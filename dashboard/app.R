source("global.R")

if (!requireNamespace("shiny", quietly = TRUE)) stop("Install the shiny package to run this dashboard.")
if (!requireNamespace("bslib", quietly = TRUE)) stop("Install the bslib package to run this dashboard.")

library(shiny)
library(bslib)

has_gg <- requireNamespace("ggplot2", quietly = TRUE)
if (has_gg) library(ggplot2)

countries <- if (nrow(dashboard_panel) > 0 && "country" %in% names(dashboard_panel)) sort(unique(dashboard_panel$country[dashboard_panel$country != ""])) else character()
years <- if (nrow(dashboard_panel) > 0 && "year" %in% names(dashboard_panel)) sort(unique(stats::na.omit(as.integer(dashboard_panel$year)))) else integer()
year_min <- if (length(years)) min(years) else 2000
year_max <- if (length(years)) max(years) else 2026
year_value <- if (length(years)) range(years) else c(2000, 2026)

read_table_safe <- function(path) if (file.exists(path)) utils::read.csv(path, check.names = FALSE) else data.frame(status = "file unavailable")

theme_fd <- bs_theme(
  version = 5,
  bg = "#F8F5EF",
  fg = "#1F2933",
  primary = "#BB1E10",
  secondary = "#2F6B9A",
  base_font = font_google("Inter"),
  heading_font = font_google("Source Serif 4")
)

status_block <- function(title = "Data unavailable") {
  div(class = "status-block", h3(title), p("The analytical panels required for empirical results are not present in this repository."), p("Restore the source data and run source('src/99_run_all.R') to populate this dashboard."))
}

kpi_card <- function(title, metric) {
  card(class = "kpi-card", card_body(div(class = "kpi-title", title), div(class = "kpi-value", kpi_value(metric))))
}

plot_credit <- function(data, y = "total_credit", title = "Credit evolution") {
  if (!has_gg || nrow(data) == 0 || !(y %in% names(data))) return(NULL)
  ggplot(data, aes(year, .data[[y]], color = country)) +
    geom_line(linewidth = 0.8, na.rm = TRUE) +
    labs(x = NULL, y = gsub("_", " ", y), title = title) +
    theme_minimal(base_size = 13) +
    theme(legend.position = "bottom")
}

ui <- page_navbar(
  title = "Financial Development Analytics Dashboard",
  theme = theme_fd,
  header = tags$head(
    tags$link(rel = "stylesheet", href = "style.css"),
    tags$script(HTML("$(document).on('change', '#dark_mode', function(){ $('body').toggleClass('dark-dashboard', this.checked); });"))
  ),
  nav_panel(
    "Executive",
    layout_sidebar(
      sidebar = sidebar(
        checkboxInput("dark_mode", "Dark theme", FALSE),
        selectInput("country_filter", "Country", choices = c("All", countries)),
        sliderInput("year_filter", "Year", min = year_min, max = year_max, value = year_value, sep = "")
      ),
      layout_columns(
        kpi_card("Countries", "countries"), kpi_card("Years", "years"), kpi_card("Observations", "observations"), kpi_card("Total credit", "total_credit"),
        kpi_card("Productive credit", "productive_credit"), kpi_card("Average productive share", "average_productive_share"), kpi_card("Most financed sector", "most_financed_sector"), kpi_card("Most diversified country", "most_diversified_country"),
        col_widths = c(3,3,3,3,3,3,3,3)
      ),
      card(full_screen = TRUE, card_header("Main credit view"), plotOutput("overview_plot", height = "460px"))
    )
  ),
  nav_panel("Country Explorer", layout_sidebar(sidebar = sidebar(selectInput("country_one", "Country", choices = countries)), card(card_header("Country credit path"), plotOutput("country_plot", height = "420px")), card(card_header("Country profile"), verbatimTextOutput("country_profile")))) ,
  nav_panel("Sector Explorer", card(card_header("Sector profiles"), tableOutput("sector_table"))),
  nav_panel("Bolivia", card(card_header("Bolivia versus regional comparators"), plotOutput("bolivia_plot", height = "430px")), card(card_header("Policy narrative"), p("Bolivia-focused interpretation will be generated after source data are restored."))),
  nav_panel("Time Series", card(card_header("Total credit"), plotOutput("timeseries_total", height = "420px")), card(card_header("Productive credit share"), plotOutput("timeseries_share", height = "420px"))),
  nav_panel("Maps", card(card_header("Regional snapshot"), status_block("Map pending real geographic indicators"))),
  nav_panel("Rankings", card(card_header("Country rankings"), tableOutput("ranking_table")), downloadButton("download_rankings", "Download rankings")),
  nav_panel("Data Quality", card(card_header("KPI data"), tableOutput("kpi_table")), card(card_header("Panel coverage"), tableOutput("coverage_table")), card(card_header("Panel preview"), tableOutput("panel_preview"))),
  nav_panel("Econometric Results", card(card_header("Model status"), tableOutput("model_table")), downloadButton("download_models", "Download model table")),
  nav_panel("Download Center", layout_columns(
    card(card_header("Dashboard data"), p("Download the dashboard panel used by this application."), downloadButton("download_dashboard_data", "CSV")),
    card(card_header("Data recovery status"), p("Download the current recovery audit table."), downloadButton("download_recovery", "CSV")),
    card(card_header("Figure catalog"), p("Download the current figure catalog."), downloadButton("download_figures", "CSV")),
    col_widths = c(4,4,4)
  )),
  nav_panel("Methods", card(card_header("Methods"), p("The dashboard reads outputs generated by src/99_run_all.R."), p("Indicators include productive-credit share, credit growth, sector concentration, diversification, volatility, and crisis-period markers."), p("Models and advanced visuals are generated only when source panel data exist.")))
)

server <- function(input, output, session) {
  filtered <- reactive({
    df <- dashboard_panel
    if (nrow(df) == 0) return(df)
    if ("country" %in% names(df) && !is.null(input$country_filter) && input$country_filter != "All") df <- df[df$country == input$country_filter, ]
    if ("year" %in% names(df)) df <- df[df$year >= input$year_filter[1] & df$year <= input$year_filter[2], ]
    df
  })

  render_credit_plot <- function(data, y, title, empty) {
    p <- plot_credit(data, y, title)
    if (is.null(p)) { plot.new(); text(0.5, 0.5, empty) } else print(p)
  }

  output$overview_plot <- renderPlot(render_credit_plot(filtered(), "total_credit", "Credit evolution", "Data unavailable. Restore source panels and rerun the pipeline."))
  output$country_plot <- renderPlot({ df <- dashboard_panel; if (length(input$country_one)) df <- df[df$country == input$country_one, ]; render_credit_plot(df, "total_credit", "Country credit path", "Country data unavailable.") })
  output$bolivia_plot <- renderPlot({ df <- dashboard_panel; if (nrow(df) > 0 && "country" %in% names(df)) df <- df[df$country %in% c("Bolivia","Peru","Chile","Colombia","Brazil","Argentina"), ]; render_credit_plot(df, "productive_credit_share", "Bolivia in regional perspective", "Bolivia comparison unavailable.") })
  output$timeseries_total <- renderPlot(render_credit_plot(filtered(), "total_credit", "Total credit over time", "Total credit series unavailable."))
  output$timeseries_share <- renderPlot(render_credit_plot(filtered(), "productive_credit_share", "Productive credit share over time", "Productive share series unavailable."))

  output$country_profile <- renderText({ if (!length(input$country_one)) "No country selected." else paste("Profile for", input$country_one, "will be generated after the data pipeline is populated.") })
  output$sector_table <- renderTable(read_table_safe(file.path(dashboard_root, "outputs", "tables", "sector_profiles.csv")))
  output$ranking_table <- renderTable(read_table_safe(file.path(dashboard_root, "outputs", "tables", "country_ranking.csv")))
  output$kpi_table <- renderTable(dashboard_kpi)
  output$coverage_table <- renderTable(read_table_safe(file.path(dashboard_root, "outputs", "tables", "panel_coverage.csv")))
  output$panel_preview <- renderTable(utils::head(dashboard_panel, 20))
  output$model_table <- renderTable(read_table_safe(file.path(dashboard_root, "outputs", "tables", "econometric_results.csv")))

  output$download_dashboard_data <- downloadHandler(filename = function() "dashboard_panel.csv", content = function(file) file.copy(file.path(dashboard_root, "outputs", "dashboard", "dashboard_panel.csv"), file))
  output$download_recovery <- downloadHandler(filename = function() "data_recovery_status.csv", content = function(file) file.copy(file.path(dashboard_root, "outputs", "tables", "data_recovery_status.csv"), file))
  output$download_figures <- downloadHandler(filename = function() "figure_catalog.csv", content = function(file) file.copy(file.path(dashboard_root, "outputs", "figures", "figure_catalog.csv"), file))
  output$download_rankings <- downloadHandler(filename = function() "country_ranking.csv", content = function(file) file.copy(file.path(dashboard_root, "outputs", "tables", "country_ranking.csv"), file))
  output$download_models <- downloadHandler(filename = function() "econometric_results.csv", content = function(file) file.copy(file.path(dashboard_root, "outputs", "tables", "econometric_results.csv"), file))
}

shinyApp(ui, server)
