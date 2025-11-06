# Task 22b: Ensure NEWS.md has a 0.1.0 section with today's date.

if (file.exists("renv/activate.R")) try(source("renv/activate.R"), silent = TRUE)
today <- format(Sys.Date(), "%Y-%m-%d")
target <- "0.1.0"

stopifnot(file.exists("NEWS.md"))
txt <- readLines("NEWS.md", warn = FALSE, encoding = "UTF-8")

has_header <- any(grepl(sprintf("^#\\s*zashboard\\s+%s\\b", gsub("\\.", "\\\\.", target)),
                        tolower(txt)))

release_block <- c(
  sprintf("# zashboard %s (%s)", target, today),
  "",
  "- Initial public release.",
  "- One spec builds **four targets**: static HTML, Shiny app, Shinylive app, and a Quarto site.",
  "- Build helpers: `build_static()`, `build_shiny()`, `build_shinylive()`, `build_quarto()`, `build_all()`.",
  "- Connectors: DuckDB, Arrow, and Microsoft SQL Server (via DBI/ODBC).",
  "- Validation helpers for spec and manifest; unified theming with {bslib}.",
  ""
)

if (!has_header) {
  writeLines(c(release_block, txt), "NEWS.md", useBytes = TRUE)
  cat("Wrote 0.1.0 header to NEWS.md\n")
} else {
  # If a header exists but says "(unreleased)", stamp the date
  new <- gsub("\\(unreleased\\)", paste0("(", today, ")"), txt, ignore.case = TRUE)
  if (!identical(new, txt)) {
    writeLines(new, "NEWS.md", useBytes = TRUE)
    cat("Stamped date on existing 0.1.0 header in NEWS.md\n")
  } else {
    cat("0.1.0 header already present with a date. No changes.\n")
  }
}
