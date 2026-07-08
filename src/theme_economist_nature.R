if (!exists("ROOT")) source(file.path("src", "00_setup.R"))

editorial_palette <- c(
  red = "#BB1E10",
  navy = "#1F2933",
  blue = "#2F6B9A",
  teal = "#3E8C84",
  gold = "#C99A2E",
  gray = "#6B7280",
  light_gray = "#E5E7EB",
  paper = "#F8F5EF"
)

theme_economist_nature <- function(base_size = 12, base_family = "") {
  if (!has_pkg("ggplot2")) return(NULL)
  ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(fill = "white", color = NA),
      panel.background = ggplot2::element_rect(fill = "white", color = NA),
      panel.grid.major = ggplot2::element_line(color = "#E6E6E6", linewidth = 0.25),
      panel.grid.minor = ggplot2::element_blank(),
      axis.title = ggplot2::element_text(color = editorial_palette["navy"]),
      axis.text = ggplot2::element_text(color = editorial_palette["navy"]),
      plot.title = ggplot2::element_text(face = "bold", color = editorial_palette["navy"], size = base_size + 4),
      plot.subtitle = ggplot2::element_text(color = editorial_palette["gray"], size = base_size + 1),
      plot.caption = ggplot2::element_text(color = editorial_palette["gray"], size = base_size - 2),
      legend.position = "bottom",
      legend.title = ggplot2::element_blank(),
      strip.text = ggplot2::element_text(face = "bold", color = editorial_palette["navy"])
    )
}

save_editorial_plot <- function(plot, name, width = 10, height = 6) {
  if (!has_pkg("ggplot2")) stop("ggplot2 is required to save ggplot figures.")
  png_file <- path("outputs", "figures", paste0(name, ".png"))
  pdf_file <- path("outputs", "figures", paste0(name, ".pdf"))
  ggplot2::ggsave(png_file, plot, width = width, height = height, dpi = 300)
  ggplot2::ggsave(pdf_file, plot, width = width, height = height, device = grDevices::cairo_pdf)
  invisible(c(png_file, pdf_file))
}

make_status_figure <- function(name, title, message) {
  png_file <- path("outputs", "figures", paste0(name, ".png"))
  pdf_file <- path("outputs", "figures", paste0(name, ".pdf"))
  dir.create(dirname(png_file), recursive = TRUE, showWarnings = FALSE)
  draw <- function() {
    par(mar = c(3, 3, 4, 3), family = "")
    plot.new()
    rect(0, 0, 1, 1, col = "white", border = NA)
    segments(0.08, 0.82, 0.92, 0.82, col = editorial_palette["red"], lwd = 4)
    text(0.08, 0.68, title, adj = 0, cex = 1.45, font = 2, col = editorial_palette["navy"])
    text(0.08, 0.52, message, adj = 0, cex = 0.95, col = editorial_palette["gray"])
    text(0.08, 0.18, "FinancialData | data-unavailable placeholder", adj = 0, cex = 0.75, col = editorial_palette["gray"])
  }
  grDevices::png(png_file, width = 3000, height = 1800, res = 300)
  draw()
  grDevices::dev.off()
  grDevices::pdf(pdf_file, width = 10, height = 6)
  draw()
  grDevices::dev.off()
  invisible(c(png_file, pdf_file))
}
