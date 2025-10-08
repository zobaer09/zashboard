# 2025-10-08: Build data and render static site (outline)
# 1) Pull data (DBI/odbc or files)
# 2) Write partitioned Parquet and manifest.json into ./site/
# 3) Copy www assets into ./site/
# 4) Optionally render Quarto

dir.create("site", showWarnings = FALSE)

# TODO: wire to package functions later
file.copy("www/index.html", "site/index.html", overwrite = TRUE)
file.copy("www/zash-client.js", "site/zash-client.js", overwrite = TRUE)
file.copy("www/service-worker.js", "site/service-worker.js", overwrite = TRUE)

manifest <- list(
  version = "2025-10-08",
  datasets = list()
)
jsonlite::write_json(manifest, "site/manifest.json", auto_unbox = TRUE)
