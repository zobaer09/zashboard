# scripts/task25_release_files.R
ver <- as.character(desc::desc_get_version())
if (!file.exists("NEWS.md")) {
  writeLines(sprintf("# zashboard %s\n\n- First CRAN release.\n", ver), "NEWS.md")
  cat("Created NEWS.md\n")
}
if (!file.exists("cran-comments.md")) {
  cc <- c(
    "## Test environments",
    "* local Windows, R 4.3",
    "* GitHub Actions: Windows, macOS, Ubuntu (release/devel/oldrel)",
    "",
    "## R CMD check results",
    "* 0 errors | 0 warnings | 0 notes (locally).",
    "",
    "## Vignettes",
    "* Built quickly; Quarto render is skipped in CRAN builds.",
    "",
    "## Downstream dependencies",
    "* None (first release)."
  )
  writeLines(cc, "cran-comments.md")
  cat("Created cran-comments.md\n")
}
cat("Open and tweak NEWS.md and cran-comments.md as needed.\n")
