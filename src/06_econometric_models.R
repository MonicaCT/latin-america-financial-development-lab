if (!exists("ROOT")) source(file.path("src", "00_setup.R"))
if (!exists("financial_panel")) source(path("src", "04_descriptive_analysis.R"))

needed <- c("productive_credit_share", "sector_concentration_hhi", "credit_growth_yoy", "credit_volatility", "country", "year")
model_ready <- nrow(financial_panel) > 0 && all(needed %in% names(financial_panel)) &&
  sum(stats::complete.cases(financial_panel[, needed])) >= 30 &&
  length(unique(financial_panel$country)) >= 3

if (!model_ready) {
  econ <- data.frame(
    model = c("Pooled OLS", "Country fixed effects", "Two-way fixed effects", "Random effects", "Hausman test", "Driscoll-Kraay", "Lagged models"),
    status = "not estimated",
    reason = "Required panel data are unavailable or insufficient.",
    stringsAsFactors = FALSE
  )
  write_csv_safe(econ, path("outputs", "tables", "econometric_results.csv"))
  write_text_safe(c("<html><body><h1>Model summary</h1><p>Models were not estimated because required panel data are unavailable or insufficient.</p></body></html>"), path("outputs", "models", "model_summary.html"))
  write_text_safe(c("\\begin{tabular}{ll}", "Model & Status\\\\", "Panel models & Not estimated: data unavailable\\\\", "\\end{tabular}"), path("outputs", "models", "model_summary.tex"))
  append_status(status_row("06_econometric_models", "complete_without_data", "Model outputs written as non-estimation status files."))
  message("06_econometric_models complete without estimation")
} else {
  df <- financial_panel[stats::complete.cases(financial_panel[, needed]), ]
  results <- list()

  pooled <- stats::lm(productive_credit_share ~ sector_concentration_hhi + credit_growth_yoy + credit_volatility, data = df)
  results[["Pooled OLS"]] <- pooled

  fe_country <- stats::lm(productive_credit_share ~ sector_concentration_hhi + credit_growth_yoy + credit_volatility + factor(country), data = df)
  results[["Country fixed effects"]] <- fe_country

  twfe <- stats::lm(productive_credit_share ~ sector_concentration_hhi + credit_growth_yoy + credit_volatility + factor(country) + factor(year), data = df)
  results[["Two-way fixed effects"]] <- twfe

  tidy_lm <- function(model_name, fit) {
    co <- summary(fit)$coefficients
    data.frame(
      model = model_name,
      term = rownames(co),
      estimate = co[, 1],
      std_error = co[, 2],
      statistic = co[, 3],
      p_value = co[, 4],
      stringsAsFactors = FALSE
    )
  }
  econ <- do.call(rbind, Map(tidy_lm, names(results), results))
  write_csv_safe(econ, path("outputs", "tables", "econometric_results.csv"))

  if (has_pkg("modelsummary")) {
    modelsummary::modelsummary(results, output = path("outputs", "models", "model_summary.html"))
    modelsummary::modelsummary(results, output = path("outputs", "models", "model_summary.tex"))
  } else {
    html <- c("<html><body><h1>Model summary</h1><pre>", capture.output(summary(twfe)), "</pre></body></html>")
    write_text_safe(html, path("outputs", "models", "model_summary.html"))
    write_text_safe(c("\\begin{verbatim}", capture.output(summary(twfe)), "\\end{verbatim}"), path("outputs", "models", "model_summary.tex"))
  }
  append_status(status_row("06_econometric_models", "complete_with_data", "Estimated OLS and fixed-effect specifications."))
  message("06_econometric_models complete")
}
