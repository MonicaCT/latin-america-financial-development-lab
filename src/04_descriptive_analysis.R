if (!exists("ROOT")) source(file.path("src", "00_setup.R"))
if (!exists("analysis_panel")) source(path("src", "02_clean_data.R"))

build_indicators <- function(df) {
  if (nrow(df) == 0) {
    out <- empty_panel()
    for (v in c(
      "total_credit", "productive_credit", "non_productive_credit",
      "productive_credit_share", "sector_concentration_hhi",
      "sector_diversification_index", "credit_growth_yoy",
      "real_credit_index", "credit_per_country_index", "credit_volatility",
      "rolling_growth_3y", "rolling_volatility_3y",
      "pre_post_crisis_dummy", "covid_period_dummy", "post_covid_dummy"
    )) out[[v]] <- numeric()
    return(out)
  }
  df <- clean_names_df(df)
  if (!"total_credit" %in% names(df)) df$total_credit <- first_existing(df, c("t_credit", "total", "total_credit_alt"))
  if (!"productive_credit" %in% names(df)) df$productive_credit <- first_existing(df, c("t_productive", "business_credit", "commercial_credit"))
  df$total_credit <- numeric_safe(df$total_credit)
  df$productive_credit <- numeric_safe(df$productive_credit)
  df$non_productive_credit <- ifelse(!is.na(df$total_credit) & !is.na(df$productive_credit), df$total_credit - df$productive_credit, NA_real_)
  df$productive_credit_share <- ifelse(df$total_credit > 0, df$productive_credit / df$total_credit, NA_real_)

  sector_vars <- intersect(sector_clean_vars, names(df))
  if (length(sector_vars) > 0) {
    sector_mat <- as.data.frame(lapply(df[sector_vars], numeric_safe))
    sector_sum <- rowSums(sector_mat, na.rm = TRUE)
    sector_sum[sector_sum == 0] <- NA_real_
    shares <- sector_mat / sector_sum
    df$sector_concentration_hhi <- rowSums(shares^2, na.rm = TRUE)
    df$sector_concentration_hhi[is.na(sector_sum)] <- NA_real_
    df$sector_diversification_index <- 1 - df$sector_concentration_hhi
  } else {
    df$sector_concentration_hhi <- NA_real_
    df$sector_diversification_index <- NA_real_
  }

  df <- df[order(df$country, df$year, df$date), ]
  df$credit_growth_yoy <- ave(df$total_credit, df$country, FUN = function(x) c(NA, x[-1] / x[-length(x)] - 1))
  df$credit_per_country_index <- ave(df$total_credit, df$country, FUN = function(x) {
    base <- x[which(!is.na(x) & x != 0)[1]]
    if (length(base) == 0 || is.na(base)) rep(NA_real_, length(x)) else x / base * 100
  })
  df$real_credit_index <- first_existing(df, c("real_total_credit_index_2018", "i_t_credit18ipc", "i_total18ipc"))
  df$credit_volatility <- ave(df$credit_growth_yoy, df$country, FUN = function(x) rep(stats::sd(x, na.rm = TRUE), length(x)))
  df$rolling_growth_3y <- ave(df$credit_growth_yoy, df$country, FUN = function(x) stats::filter(x, rep(1 / 3, 3), sides = 1))
  df$rolling_volatility_3y <- ave(df$credit_growth_yoy, df$country, FUN = function(x) {
    out <- rep(NA_real_, length(x))
    for (i in seq_along(x)) if (i >= 3) out[i] <- stats::sd(x[(i - 2):i], na.rm = TRUE)
    out
  })
  df$pre_post_crisis_dummy <- ifelse(df$year >= 2008 & df$year <= 2009, 1L, 0L)
  df$covid_period_dummy <- ifelse(df$year >= 2020 & df$year <= 2021, 1L, 0L)
  df$post_covid_dummy <- ifelse(df$year >= 2022, 1L, 0L)
  df
}

financial_panel <- build_indicators(analysis_panel)

descriptive_stats <- function(df) {
  numeric_vars <- names(df)[vapply(df, is.numeric, logical(1))]
  numeric_vars <- setdiff(numeric_vars, c("year", "pre_post_crisis_dummy", "covid_period_dummy", "post_covid_dummy"))
  if (nrow(df) == 0 || length(numeric_vars) == 0) {
    return(data.frame(variable = character(), mean = numeric(), median = numeric(), sd = numeric(), min = numeric(), max = numeric(), p25 = numeric(), p75 = numeric(), observations = integer()))
  }
  do.call(rbind, lapply(numeric_vars, function(v) {
    x <- df[[v]]
    data.frame(
      variable = v,
      mean = mean(x, na.rm = TRUE),
      median = stats::median(x, na.rm = TRUE),
      sd = stats::sd(x, na.rm = TRUE),
      min = suppressWarnings(min(x, na.rm = TRUE)),
      max = suppressWarnings(max(x, na.rm = TRUE)),
      p25 = suppressWarnings(stats::quantile(x, 0.25, na.rm = TRUE)),
      p75 = suppressWarnings(stats::quantile(x, 0.75, na.rm = TRUE)),
      observations = sum(!is.na(x)),
      stringsAsFactors = FALSE
    )
  }))
}

country_ranking <- function(df) {
  if (nrow(df) == 0 || !"country" %in% names(df)) {
    return(data.frame(
      country = character(),
      total_credit = numeric(),
      productive_credit = numeric(),
      productive_credit_share = numeric(),
      sector_concentration_hhi = numeric(),
      average_annual_growth = numeric(),
      stringsAsFactors = FALSE
    ))
  }
  latest <- do.call(rbind, lapply(split(df, df$country), function(x) x[which.max(ifelse(is.na(x$year), -Inf, x$year)), ]))
  data.frame(
    country = latest$country,
    total_credit = latest$total_credit,
    productive_credit = latest$productive_credit,
    productive_credit_share = latest$productive_credit_share,
    sector_concentration_hhi = latest$sector_concentration_hhi,
    average_annual_growth = ave(df$credit_growth_yoy, df$country, FUN = function(x) rep(mean(x, na.rm = TRUE), length(x)))[match(latest$country, df$country)],
    stringsAsFactors = FALSE
  )
}

desc_table <- descriptive_stats(financial_panel)
ranking_table <- country_ranking(financial_panel)

write_csv_safe(financial_panel, path("data", "processed", "financial_development_panel.csv"))
write_csv_safe(desc_table, path("outputs", "tables", "descriptive_statistics.csv"))
write_csv_safe(ranking_table, path("outputs", "tables", "country_ranking.csv"))

append_status(status_row(
  "04_descriptive_analysis",
  if (nrow(financial_panel) > 0) "complete_with_data" else "complete_without_data",
  paste("Financial panel rows:", nrow(financial_panel), "descriptive variables:", nrow(desc_table))
))

message("04_descriptive_analysis complete")

