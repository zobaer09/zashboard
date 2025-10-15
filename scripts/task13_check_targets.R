# scripts/task13_check_targets.R
# Scan repo text files for "three targets" so we don't miss any wording.
# Ignores this checker and vendor/output folders.

roots <- "."
ext_re <- "\\.(R|Rmd|qmd|md|yml|yaml|txt)$"
paths <- unlist(lapply(roots, function(r) list.files(r, recursive = TRUE, full.names = TRUE, pattern = ext_re)))

# Exclusions: this file + common noisy dirs
ex <- grepl("(^|/)(renv|site|docs|ci-logs|\\.git|\\.Rproj\\.user)(/|$)", paths)
ex <- ex | grepl("scripts/task13_check_targets\\.R$", paths)  # ignore self
paths <- paths[!ex]

hits <- lapply(paths, function(p) {
  txt <- tryCatch(readLines(p, warn = FALSE, encoding = "UTF-8"), error = function(e) character())
  i <- grep("three targets", txt, ignore.case = TRUE)
  if (length(i)) data.frame(file = p, line = i, text = txt[i], stringsAsFactors = FALSE)
})

res <- do.call(rbind, hits)
if (is.null(res) || nrow(res) == 0) {
  cat("✅ No remaining occurrences of 'three targets' found.\n")
} else {
  cat("❌ Found occurrences of 'three targets':\n")
  print(res, row.names = FALSE)
}
