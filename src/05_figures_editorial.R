if (!exists("ROOT")) source(file.path("src", "00_setup.R"))
source(path("src", "theme_economist_nature.R"))
if (!exists("financial_panel")) source(path("src", "04_descriptive_analysis.R"))

figure_specs <- data.frame(
  id = sprintf("figure_%02d", 1:15),
  slug = c(
    "long_run_rise_of_credit",
    "productive_vs_non_productive_credit",
    "which_countries_finance_production",
    "sectoral_credit_concentration",
    "financial_structure_fingerprints",
    "credit_diversification_map",
    "bolivia_regional_perspective",
    "credit_volatility_macro_financial_risk",
    "winners_and_laggards",
    "structural_breaks",
    "credit_allocation_by_sector",
    "country_clusters",
    "productive_transformation_dashboard_figure",
    "missing_data_transparency",
    "policy_quadrant"
  ),
  title = c(
    "The long-run rise of credit",
    "Productive credit versus non-productive credit",
    "Which countries finance production?",
    "Sectoral credit concentration",
    "Financial structure fingerprints",
    "Credit diversification map",
    "Bolivia in regional perspective",
    "Credit volatility and macro-financial risk",
    "Winners and laggards",
    "Structural breaks",
    "Credit allocation by economic sector",
    "Country clusters",
    "Productive transformation dashboard figure",
    "Missing data transparency",
    "Policy quadrant"
  ),
  stringsAsFactors = FALSE
)

figure_name <- function(i) paste0(figure_specs$id[i], "_", figure_specs$slug[i])

status_message <- "Required source data are not available in the repository. Restore cleaned panels and rerun src/99_run_all.R."

if (nrow(financial_panel) == 0 || !has_pkg("ggplot2")) {
  for (i in seq_len(nrow(figure_specs))) {
    make_status_figure(figure_name(i), figure_specs$title[i], status_message)
  }
  figure_catalog <- transform(
    figure_specs,
    png = file.path("outputs", "figures", paste0(id, "_", slug, ".png")),
    pdf = file.path("outputs", "figures", paste0(id, "_", slug, ".pdf")),
    status = ifelse(has_pkg("ggplot2"), "data unavailable", "ggplot2 unavailable")
  )
  write_csv_safe(figure_catalog, path("outputs", "figures", "figure_catalog.csv"))
  write_text_safe(c("# Figure Catalog", "", "All figures are data-unavailable placeholders until source data are restored."), path("outputs", "figures", "figure_catalog.md"))
  append_status(status_row("05_figures_editorial", "complete_without_data", "Created data-unavailable figure placeholders."))
  message("05_figures_editorial complete without data")
} else {
  load_pkg("ggplot2")
  has_patchwork <- load_pkg("patchwork")

  panel <- financial_panel
  theme_set <- theme_economist_nature()

  p1 <- ggplot2::ggplot(panel, ggplot2::aes(year, credit_per_country_index, color = country, group = country)) +
    ggplot2::geom_line(linewidth = 0.7, alpha = 0.85, na.rm = TRUE) +
    ggplot2::labs(title = figure_specs$title[1], subtitle = "Country-specific base-100 index from first available observation.", x = NULL, y = "Index") +
    theme_set
  save_editorial_plot(p1, figure_name(1))

  comp <- panel[, intersect(c("country", "year", "productive_credit", "non_productive_credit"), names(panel)), drop = FALSE]
  comp_long <- if (nrow(comp) > 0) {
    rbind(
      data.frame(country = comp$country, year = comp$year, type = "Productive", value = comp$productive_credit),
      data.frame(country = comp$country, year = comp$year, type = "Non-productive", value = comp$non_productive_credit)
    )
  } else data.frame()
  p2 <- ggplot2::ggplot(comp_long, ggplot2::aes(year, value, color = type)) +
    ggplot2::geom_line(linewidth = 0.7, na.rm = TRUE) +
    ggplot2::facet_wrap(~country, scales = "free_y") +
    ggplot2::scale_color_manual(values = c("Productive" = editorial_palette["red"], "Non-productive" = editorial_palette["blue"])) +
    ggplot2::labs(title = figure_specs$title[2], subtitle = "Comparison is shown only where both components are available.", x = NULL, y = "Source units") +
    theme_set
  save_editorial_plot(p2, figure_name(2), 11, 7)

  latest <- do.call(rbind, lapply(split(panel, panel$country), function(x) x[which.max(ifelse(is.na(x$year), -Inf, x$year)), ]))
  latest <- latest[order(latest$productive_credit_share), ]
  p3 <- ggplot2::ggplot(latest, ggplot2::aes(productive_credit_share, stats::reorder(country, productive_credit_share))) +
    ggplot2::geom_col(fill = editorial_palette["red"], alpha = 0.9, na.rm = TRUE) +
    ggplot2::scale_x_continuous(labels = scales::percent_format(accuracy = 1)) +
    ggplot2::labs(title = figure_specs$title[3], subtitle = "Latest available productive-credit share.", x = "Productive credit share", y = NULL) +
    theme_set
  save_editorial_plot(p3, figure_name(3))

  sector_vars <- intersect(sector_clean_vars, names(panel))
  if (length(sector_vars) > 0) {
    s_latest <- latest
    sector_long <- do.call(rbind, lapply(sector_vars, function(v) {
      data.frame(country = s_latest$country, sector = gsub("_credit", "", v), value = numeric_safe(s_latest[[v]]), stringsAsFactors = FALSE)
    }))
    sector_long <- sector_long[!is.na(sector_long$value), ]
    sector_long$share <- ave(sector_long$value, sector_long$country, FUN = function(x) x / sum(x, na.rm = TRUE))
    p4 <- ggplot2::ggplot(sector_long, ggplot2::aes(sector, country, fill = share)) +
      ggplot2::geom_tile(color = "white", linewidth = 0.25) +
      ggplot2::scale_fill_viridis_c(option = "C", labels = scales::percent) +
      ggplot2::labs(title = figure_specs$title[4], subtitle = "Latest available sector shares.", x = NULL, y = NULL) +
      theme_set
    save_editorial_plot(p4, figure_name(4))

    p5 <- ggplot2::ggplot(sector_long, ggplot2::aes(sector, share, fill = sector)) +
      ggplot2::geom_col(show.legend = FALSE) +
      ggplot2::facet_wrap(~country) +
      ggplot2::scale_y_continuous(labels = scales::percent) +
      ggplot2::labs(title = figure_specs$title[5], subtitle = "Sectoral composition fingerprints by country.", x = NULL, y = "Share") +
      theme_set
    save_editorial_plot(p5, figure_name(5), 11, 7)

    p11 <- ggplot2::ggplot(sector_long, ggplot2::aes(stats::reorder(sector, value), value, fill = sector)) +
      ggplot2::geom_col(show.legend = FALSE) +
      ggplot2::coord_flip() +
      ggplot2::labs(title = figure_specs$title[11], subtitle = "Aggregate observed allocation across latest country observations.", x = NULL, y = "Observed credit") +
      theme_set
    save_editorial_plot(p11, figure_name(11))
  } else {
    for (i in c(4, 5, 11)) make_status_figure(figure_name(i), figure_specs$title[i], "Sector variables are unavailable.")
  }

  p6 <- ggplot2::ggplot(latest, ggplot2::aes(sector_diversification_index, stats::reorder(country, sector_diversification_index))) +
    ggplot2::geom_col(fill = editorial_palette["teal"], na.rm = TRUE) +
    ggplot2::labs(title = figure_specs$title[6], subtitle = "Map-ready ranking shown when geographic packages are unavailable.", x = "Diversification index", y = NULL) +
    theme_set
  save_editorial_plot(p6, figure_name(6))

  bolivia_neighbors <- c("Bolivia", "Peru", "Chile", "Colombia", "Brazil", "Argentina")
  bdat <- panel[panel$country %in% bolivia_neighbors, ]
  regional <- aggregate(productive_credit_share ~ year, data = panel, FUN = mean, na.rm = TRUE)
  regional$country <- "Regional average"
  bplot <- rbind(bdat[, c("country", "year", "productive_credit_share")], regional[, c("country", "year", "productive_credit_share")])
  p7 <- ggplot2::ggplot(bplot, ggplot2::aes(year, productive_credit_share, color = country, linewidth = country == "Bolivia")) +
    ggplot2::geom_line(na.rm = TRUE) +
    ggplot2::scale_y_continuous(labels = scales::percent) +
    ggplot2::scale_linewidth_manual(values = c("TRUE" = 1.1, "FALSE" = 0.5), guide = "none") +
    ggplot2::labs(title = figure_specs$title[7], subtitle = "Bolivia against neighbors and the regional average.", x = NULL, y = "Productive credit share") +
    theme_set
  save_editorial_plot(p7, figure_name(7))

  risk <- aggregate(cbind(credit_growth_yoy, credit_volatility, total_credit) ~ country, data = panel, FUN = mean, na.rm = TRUE)
  p8 <- ggplot2::ggplot(risk, ggplot2::aes(credit_growth_yoy, credit_volatility, size = total_credit, label = country)) +
    ggplot2::geom_point(color = editorial_palette["red"], alpha = 0.75, na.rm = TRUE) +
    ggplot2::geom_text(check_overlap = TRUE, size = 3, nudge_y = 0.01, na.rm = TRUE) +
    ggplot2::scale_x_continuous(labels = scales::percent) +
    ggplot2::scale_y_continuous(labels = scales::percent) +
    ggplot2::labs(title = figure_specs$title[8], subtitle = "Average growth versus volatility.", x = "Average credit growth", y = "Credit volatility") +
    theme_set
  save_editorial_plot(p8, figure_name(8))

  endpoints <- do.call(rbind, lapply(split(panel, panel$country), function(x) {
    x <- x[order(x$year), ]
    rbind(head(x, 1), tail(x, 1))
  }))
  p9 <- ggplot2::ggplot(endpoints, ggplot2::aes(year, credit_per_country_index, group = country)) +
    ggplot2::geom_line(color = editorial_palette["gray"], na.rm = TRUE) +
    ggplot2::geom_point(color = editorial_palette["red"], na.rm = TRUE) +
    ggplot2::facet_wrap(~country) +
    ggplot2::labs(title = figure_specs$title[9], subtitle = "First versus latest available observation.", x = NULL, y = "Credit index") +
    theme_set
  save_editorial_plot(p9, figure_name(9), 11, 7)

  p10 <- ggplot2::ggplot(panel, ggplot2::aes(year, credit_per_country_index, color = country)) +
    ggplot2::geom_line(alpha = 0.5, na.rm = TRUE) +
    ggplot2::geom_smooth(se = FALSE, linewidth = 0.7, na.rm = TRUE) +
    ggplot2::labs(title = figure_specs$title[10], subtitle = "Visual trend shifts using smoothed credit-index paths.", x = NULL, y = "Credit index") +
    theme_set
  save_editorial_plot(p10, figure_name(10))

  cluster_vars <- c("productive_credit_share", "sector_concentration_hhi", "sector_diversification_index", "credit_growth_yoy", "credit_volatility")
  cl <- aggregate(panel[, intersect(cluster_vars, names(panel)), drop = FALSE], list(country = panel$country), mean, na.rm = TRUE)
  complete_cl <- stats::complete.cases(cl[, intersect(cluster_vars, names(cl)), drop = FALSE])
  if (sum(complete_cl) >= 3) {
    scaled <- scale(cl[complete_cl, cluster_vars])
    pcs <- stats::prcomp(scaled, center = FALSE, scale. = FALSE)
    pca <- data.frame(country = cl$country[complete_cl], pc1 = pcs$x[, 1], pc2 = pcs$x[, 2])
    p12 <- ggplot2::ggplot(pca, ggplot2::aes(pc1, pc2, label = country)) +
      ggplot2::geom_point(color = editorial_palette["red"], size = 3) +
      ggplot2::geom_text(check_overlap = TRUE, nudge_y = 0.08, size = 3) +
      ggplot2::labs(title = figure_specs$title[12], subtitle = "PCA view of country credit-structure profiles.", x = "PC1", y = "PC2") +
      theme_set
    save_editorial_plot(p12, figure_name(12))
  } else {
    make_status_figure(figure_name(12), figure_specs$title[12], "Not enough complete country profiles for clustering.")
  }

  p13 <- if (has_patchwork) {
    p3 + p8 + patchwork::plot_annotation(title = figure_specs$title[13])
  } else {
    p3 + ggplot2::labs(title = figure_specs$title[13])
  }
  save_editorial_plot(p13, figure_name(13), 12, 7)

  availability <- panel[, intersect(c("country", "year", "total_credit"), names(panel)), drop = FALSE]
  availability$available <- !is.na(availability$total_credit)
  p14 <- ggplot2::ggplot(availability, ggplot2::aes(year, country, fill = available)) +
    ggplot2::geom_tile(color = "white", linewidth = 0.2) +
    ggplot2::scale_fill_manual(values = c("TRUE" = editorial_palette["red"], "FALSE" = "#E5E7EB")) +
    ggplot2::labs(title = figure_specs$title[14], subtitle = "Availability of total credit by country-year.", x = NULL, y = NULL) +
    theme_set
  save_editorial_plot(p14, figure_name(14))

  p15 <- ggplot2::ggplot(latest, ggplot2::aes(productive_credit_share, sector_diversification_index, size = total_credit, color = country)) +
    ggplot2::geom_point(alpha = 0.85, na.rm = TRUE) +
    ggplot2::geom_vline(xintercept = stats::median(latest$productive_credit_share, na.rm = TRUE), linetype = "dashed", color = editorial_palette["gray"]) +
    ggplot2::geom_hline(yintercept = stats::median(latest$sector_diversification_index, na.rm = TRUE), linetype = "dashed", color = editorial_palette["gray"]) +
    ggplot2::scale_x_continuous(labels = scales::percent) +
    ggplot2::labs(title = figure_specs$title[15], subtitle = "Productive-credit share versus sector diversification.", x = "Productive credit share", y = "Diversification index") +
    theme_set
  save_editorial_plot(p15, figure_name(15))

  figure_catalog <- transform(
    figure_specs,
    png = file.path("outputs", "figures", paste0(id, "_", slug, ".png")),
    pdf = file.path("outputs", "figures", paste0(id, "_", slug, ".pdf")),
    status = "generated"
  )
  write_csv_safe(figure_catalog, path("outputs", "figures", "figure_catalog.csv"))
  write_text_safe(c("# Figure Catalog", "", paste("- `", figure_catalog$png, "`", sep = "")), path("outputs", "figures", "figure_catalog.md"))
  append_status(status_row("05_figures_editorial", "complete_with_data", "Generated editorial figures."))
  message("05_figures_editorial complete")
}

