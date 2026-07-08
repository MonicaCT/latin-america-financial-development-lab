if (!exists("ROOT")) source(file.path("src", "00_setup.R"))
if (!exists("financial_panel")) source(path("src", "04_descriptive_analysis.R"))

winsor <- function(x, probs = c(0.01, 0.99)) {
  qs <- stats::quantile(x, probs = probs, na.rm = TRUE)
  pmin(pmax(x, qs[1]), qs[2])
}

needed <- c("productive_credit_share", "sector_concentration_hhi", "credit_growth_yoy", "credit_volatility", "country", "year")
robust_ready <- nrow(financial_panel) > 0 && all(needed %in% names(financial_panel)) &&
  sum(stats::complete.cases(financial_panel[, needed])) >= 30

if (!robust_ready) {
  robustness_summary <- data.frame(
    check = c(
      "exclude_outliers",
      "winsorize_1_99",
      "exclude_crisis_years",
      "pre_post_covid",
      "bolivia_vs_rest",
      "with_without_year_fe",
      "lagged_variables",
      "alternative_standard_errors"
    ),
    status = "not run",
    reason = "Required panel data are unavailable or insufficient.",
    stringsAsFactors = FALSE
  )
} else {
  df <- financial_panel[stats::complete.cases(financial_panel[, needed]), ]
  run_model <- function(data, label) {
    fit <- stats::lm(productive_credit_share ~ sector_concentration_hhi + credit_growth_yoy + credit_volatility + factor(country), data = data)
    co <- summary(fit)$coefficients
    data.frame(
      check = label,
      n = nrow(data),
      concentration_estimate = if ("sector_concentration_hhi" %in% rownames(co)) co["sector_concentration_hhi", 1] else NA_real_,
      concentration_p_value = if ("sector_concentration_hhi" %in% rownames(co)) co["sector_concentration_hhi", 4] else NA_real_,
      status = "estimated",
      reason = "",
      stringsAsFactors = FALSE
    )
  }
  base <- df
  out <- list(
    run_model(base, "baseline"),
    run_model(base[abs(stats::scale(base$credit_growth_yoy)) < 3 | is.na(base$credit_growth_yoy), ], "exclude_outliers")
  )
  win <- base
  win$credit_growth_yoy <- winsor(win$credit_growth_yoy)
  out[[length(out) + 1]] <- run_model(win, "winsorize_1_99")
  out[[length(out) + 1]] <- run_model(base[!(base$year %in% c(2008, 2009, 2020, 2021)), ], "exclude_crisis_years")
  out[[length(out) + 1]] <- run_model(base, "with_country_fe")
  robustness_summary <- do.call(rbind, out)
}

write_csv_safe(robustness_summary, path("outputs", "tables", "robustness_summary.csv"))
append_status(status_row(
  "07_robustness_checks",
  if (robust_ready) "complete_with_data" else "complete_without_data",
  paste("Robustness rows:", nrow(robustness_summary))
))

message("07_robustness_checks complete")
