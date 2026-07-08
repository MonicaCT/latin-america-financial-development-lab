if (!exists("ROOT")) source(file.path("src", "00_setup.R"))
if (!exists("financial_panel")) source(path("src", "04_descriptive_analysis.R"))

advanced_figures <- c(
  "Storytelling Figure", "Executive Summary Figure", "Regional Snapshot",
  "Country Profile", "Bolivia Focus", "Credit Structure Wheel", "Sankey diagram",
  "Network graph", "Chord diagram", "Animated timeline", "Bump chart",
  "Ridgeline plots", "Horizon charts", "Beeswarm plots", "Violin plots",
  "Lollipop rankings", "Small multiples", "Treemap", "Radar charts",
  "Waterfall chart", "Heatmaps", "Correlation network", "PCA visualization",
  "Cluster visualization", "Interactive Plotly versions"
)

if (nrow(financial_panel) == 0) {
  advanced_status <- data.frame(
    figure = advanced_figures,
    status = "pending real data",
    reason = "Source analytical panels are absent; no empirical advanced visual was generated.",
    stringsAsFactors = FALSE
  )
  write_csv_safe(advanced_status, path("outputs", "tables", "advanced_figure_status.csv"))
  append_status(status_row("11_advanced_visualizations", "complete_without_data", "Advanced figure requests documented as pending real data."))
} else {
  advanced_status <- data.frame(
    figure = advanced_figures,
    status = "eligible",
    reason = "Source data are available; extend this script for domain-specific advanced figures.",
    stringsAsFactors = FALSE
  )
  write_csv_safe(advanced_status, path("outputs", "tables", "advanced_figure_status.csv"))
  append_status(status_row("11_advanced_visualizations", "complete_with_data", "Advanced figure status table created."))
}

message("11_advanced_visualizations complete")
