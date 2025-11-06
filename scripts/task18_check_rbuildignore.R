# Check that flagged files/dirs will be ignored by .Rbuildignore

rb <- ".Rbuildignore"
stopifnot(file.exists(rb))
patterns <- readLines(rb, warn = FALSE)

# Files CRAN previously flagged at top level:
targets <- c(
  "CHECKLIST.md", "SPEC.md", "CODE_OF_CONDUCT.md", "CONTRIBUTING.md", "SECURITY.md",
  "www", "zashboard-spec-starter.zip", "ci-logs", "site", "docs", "_pkgdown.yml", "scripts"
)

matches <- sapply(targets, function(f) any(grepl(paste0("^", patterns, collapse = "|"), f)))
df <- data.frame(item = targets, ignored = as.logical(matches))

print(df, row.names = FALSE)

if (all(matches)) {
  cat("\n✅ All target files/dirs are ignored by .Rbuildignore\n")
} else {
  cat("\n❌ Some items are NOT ignored. See 'ignored = FALSE' above.\n")
}
