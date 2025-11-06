# Append common non-package paths to .Rbuildignore (idempotent)

patterns <- c(
  # project docs/notes at repo top-level
  "^CHECKLIST\\.md$",
  "^SPEC\\.md$",
  "^CODE_OF_CONDUCT\\.md$",
  "^CONTRIBUTING\\.md$",
  "^SECURITY\\.md$",
  
  # local-only & generated artifacts
  "^ci-logs$",
  "^site$",
  "^docs$",
  "^pkgdown$",
  "^_pkgdown\\.yml$",
  "^scripts$",
  
  # misc repo infra
  "^\\.github$",
  "^\\.Rproj\\.user$",
  
  # top-level assets not needed in the source tarball
  "^www$",
  "^zashboard-spec-starter\\.zip$"
)

rb <- ".Rbuildignore"
old <- if (file.exists(rb)) readLines(rb, warn = FALSE) else character()
new <- unique(c(old, patterns))
writeLines(new, rb)
cat("Updated .Rbuildignore at:", normalizePath(rb, winslash = "/"), "\n")
