if (!exists("ROOT")) source(file.path("src", "00_setup.R"))

dir_create("docs", "assets", "figures")
dir_create("docs", "downloads")

if (file.exists(path("outputs", "figures", "data_recovery_audit.png"))) {
  file.copy(path("outputs", "figures", "data_recovery_audit.png"), path("docs", "assets", "figures", "data_recovery_audit.png"), overwrite = TRUE)
}

index <- c(
  "<!doctype html><html lang='en'><head><meta charset='utf-8'><meta name='viewport' content='width=device-width, initial-scale=1'>",
  "<title>Financial Development Analytics in Latin America</title>",
  "<style>body{margin:0;background:#f8f5ef;color:#1f2933;font-family:Arial,sans-serif}header,main,footer{padding:32px 24px}.wrap{max-width:1120px;margin:0 auto}h1{font-family:Georgia,serif;font-size:3rem}.card{background:white;border:1px solid #e5e7eb;border-radius:8px;padding:18px;margin:14px 0}img{max-width:100%;border:1px solid #e5e7eb;border-radius:8px}.red{color:#bb1e10}</style></head><body>",
  "<header><div class='wrap'><h1>Financial Development Analytics in Latin America</h1><p>Reproducible research lab project on credit composition and productive finance. Empirical outputs pending restored source panels.</p></div></header>",
  "<main class='wrap'><section class='card'><h2 class='red'>Data Recovery Audit</h2><img src='assets/figures/data_recovery_audit.png' alt='Data recovery audit'></section>",
  "<section class='card'><h2>Reproduce</h2><code>source(\"src/99_run_all.R\")</code></section>",
  "<section class='card'><h2>Downloads</h2><p><a href='../outputs/tables/data_recovery_status.csv'>Data recovery status</a></p></section></main>",
  "<footer><div class='wrap'>Monica Cueto Tapia</div></footer></body></html>"
)
write_text_safe(index, path("docs", "index.html"))

append_status(status_row("13_reports_and_pages", "complete", "GitHub Pages shell prepared."))
message("13_reports_and_pages complete")
