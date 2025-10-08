# scripts/check_task2.R
# Audit Task 2 setup and print a pass/fail report.

check_task2 <- function() {
  # Try to activate renv (safe if missing)
  if (file.exists("renv/activate.R")) try(source("renv/activate.R"), silent = TRUE)
  
  add <- function(name, pass, note = "") {
    list(name = name, pass = isTRUE(pass), note = note)
  }
  
  findings <- list()
  
  # renv basics
  findings[[length(findings)+1]] <- add("renv.lock present", file.exists("renv.lock"),
                                        "Run renv::snapshot(prompt = FALSE)")
  status_txt <- tryCatch(capture.output(renv::status()), error = function(e) character())
  up_to_date <- any(grepl("up to date|no issues found|consistent state", status_txt, ignore.case = TRUE)) &&
    !any(grepl("out-of-sync|problems|issues detected", status_txt, ignore.case = TRUE))
  findings[[length(findings)+1]] <- add("renv status up to date", up_to_date,
                                        "Run renv::snapshot(prompt = FALSE) again")
  
  
  # Package skeleton
  desc_exists <- file.exists("DESCRIPTION")
  findings[[length(findings)+1]] <- add("DESCRIPTION present", desc_exists,
                                        "Run usethis::create_package('.')")
  
  title_ok <- desc_ok <- license_ok <- urls_ok <- FALSE
  if (desc_exists) {
    if (!requireNamespace("desc", quietly = TRUE)) {
      message("NOTE: 'desc' not installed; skipping deep DESCRIPTION checks.")
    } else {
      d <- tryCatch(desc::desc_get(c("Title","Description","License","URL","BugReports")),
                    error = function(e) setNames(rep(NA,5), c("Title","Description","License","URL","BugReports")))
      title_ok   <- !is.na(d["Title"])       && !grepl("^What the Package Does", d["Title"])
      desc_ok    <- !is.na(d["Description"]) && !grepl("^What the package does", d["Description"], ignore.case = TRUE)
      license_ok <- !is.na(d["License"])     && grepl("MIT", d["License"])
      urls_ok    <- !is.na(d["URL"])         && nzchar(d["URL"])
    }
  }
  findings[[length(findings)+1]] <- add("DESCRIPTION Title not placeholder", title_ok,
                                        "Set a real Title via desc::desc_set()")
  findings[[length(findings)+1]] <- add("DESCRIPTION Description not placeholder", desc_ok,
                                        "Set a real Description via desc::desc_set()")
  findings[[length(findings)+1]] <- add("DESCRIPTION License is MIT", license_ok,
                                        "Run usethis::use_mit_license('Zobaer Ahmed')")
  findings[[length(findings)+1]] <- add("DESCRIPTION URLs set", urls_ok,
                                        "Set URL/BugReports in DESCRIPTION")
  
  # Spec, checklist, templates, scripts, www
  findings[[length(findings)+1]] <- add("SPEC.md present", file.exists("SPEC.md"),
                                        "Create SPEC.md in repo root")
  findings[[length(findings)+1]] <- add("CHECKLIST.md present", file.exists("CHECKLIST.md"),
                                        "Ensure from starter or create")
  findings[[length(findings)+1]] <- add("inst/templates/zashboard.yml present",
                                        file.exists("inst/templates/zashboard.yml"),
                                        "Import from starter")
  findings[[length(findings)+1]] <- add("scripts/build_static.R present",
                                        file.exists("scripts/build_static.R"),
                                        "Import from starter")
  www_ok <- dir.exists("www")
  findings[[length(findings)+1]] <- add("www/ runtime present", www_ok,
                                        "Import from starter")
  if (www_ok) {
    js_ct <- length(list.files("www", pattern = "\\.js$", recursive = TRUE))
    findings[[length(findings)+1]] <- add("www contains at least one .js", js_ct >= 1,
                                          "Add runtime JS (service worker / loader)")
  }
  
  # Tests
  findings[[length(findings)+1]] <- add("testthat scaffold (tests/testthat.R)",
                                        file.exists("tests/testthat.R"),
                                        "Run usethis::use_testthat(edition = 3)")
  tt_dir <- dir.exists("tests/testthat")
  findings[[length(findings)+1]] <- add("tests/testthat/ folder exists", tt_dir,
                                        "Run usethis::use_testthat(edition = 3)")
  tt_any <- tt_dir && length(list.files("tests/testthat", pattern = "^test-.*\\.R$", full.names = TRUE)) >= 1
  findings[[length(findings)+1]] <- add("at least one test file present", tt_any,
                                        "Add tests/testthat/test-sanity.R")
  
  # License file
  findings[[length(findings)+1]] <- add("LICENSE.md present", file.exists("LICENSE.md"),
                                        "Run usethis::use_mit_license('Zobaer Ahmed')")
  
  # CI workflow
  ci_ok <- file.exists(".github/workflows/R-CMD-check.yaml") ||
    file.exists(".github/workflows/check-standard.yaml")
  findings[[length(findings)+1]] <- add("GitHub Actions R-CMD-check workflow present", ci_ok,
                                        "Run usethis::use_github_action_check_standard()")
  
  # Git remote (to GitHub)
  rem <- tryCatch(system("git remote -v", intern = TRUE), error = function(e) character())
  origin_ok <- any(grepl("^origin\\s+https?://.*github\\.com/.+zashboard(\\.git)?\\s+\\(fetch\\)", rem))
  findings[[length(findings)+1]] <- add("Git remote 'origin' points to GitHub", origin_ok,
                                        "git remote add origin https://github.com/<you>/zashboard.git")
  
  # Core packages available (in active renv)
  pkgs <- c("arrow","duckdb","DBI","shiny","bslib","htmltools","pak","tibble")
  have <- vapply(pkgs, requireNamespace, quietly = TRUE, FUN.VALUE = logical(1))
  findings[[length(findings)+1]] <- add("Core packages installed (arrow, duckdb, DBI, shiny, bslib, htmltools, pak, tibble)",
                                        all(have),
                                        paste("Install missing with renv::install(c(", paste(sprintf('"%s"', pkgs[!have]), collapse = ", "), "))"))
  
  # Print report
  cat("\n=== Zashboard Task 2 Check ===\n")
  for (x in findings) {
    cat(sprintf("%s %s%s\n",
                if (x$pass) "✅" else "❌",
                x$name,
                if (!x$pass && nzchar(x$note)) paste0(" — FIX: ", x$note) else ""))
  }
  all_ok <- all(vapply(findings, `[[`, logical(1), "pass"))
  cat("\nSummary: ", if (all_ok) "✅ All Task 2 checks passed." else "❌ Some checks failed. See FIX hints above.", "\n", sep = "")
  invisible(all_ok)
}

# Run immediately when sourced
check_task2()
