cat('=== .Rbuildignore contains ===\n')
bi <- readLines('.Rbuildignore', warn = FALSE); writeLines(bi)
need <- c('^ci-logs$', '^release-logs$', '^examples$', '^examples_out$', '^site$', '^docs$', '^cran-comments\\.md$', '^doc$')
cat('\nMissing entries:\n'); print(setdiff(need, intersect(need, bi)))
