# scripts/check_task3.R
# Audit Task 3 (metadata + pkgdown) and print a pass/fail report.

check_task3 <- function() {
  if (file.exists("renv/activate.R")) try(source("renv/activate.R"), silent = TRUE)
  
  add <- function(name, pass, note = "") list(name = name, pass = isTRUE(pass), note = note)
  
  findings <- list()
  
  # --- renv status (informational) ---
  status_txt <- tryCatch(capture.output(renv::status()), error = function(e) character())
  renv_ok <- any(grepl("up to date|no issues found|consistent state", status_txt, ignore.case = TRUE)) &&
    !any(grepl("out-of-sync|problems|issues detected", status_txt, ignore.case = TRUE))
  findings[[length(findings)+1]] <- add("renv status consistent", renv_ok,
                                        "Run renv::snapshot(prompt = FALSE)")
  
  # --- DESCRIPTION checks ---
  desc_exists <- file.exists("DESCRIPTION")
  findings[[length(findings)+1]] <- add("DESCRIPTION present", desc_exists,
                                        "Run usethis::create_package('.')")
  
  # Use desc if available, otherwise fallback to DCF
  get_desc <- function(fields) {
    if (requireNamespace("desc", quietly = TRUE)) {
      out <- tryCatch(desc::desc_get(fields), error = function(e) setNames(rep(NA_character_, length(fields)), fields))
      return(out)
    } else {
      if (!file.exists("DESCRIPTION")) return(setNames(rep(NA_character_, length(fields)), fields))
      d <- read.dcf("DESCRIPTION")
      out <- setNames(rep(NA_character_, length(fields)), fields)
      for (f in fields) if (f %in% colnames(d)) out[[f]] <- d[1, f]
      return(out)
    }
  }
  
  d <- get_desc(c("Package","Title","Description","License","Depends","URL","BugReports","Config/testthat/edition"))
  title_ok <- !is.na(d["Title"])       && !grepl("^What the Package Does", d["Title"])
  desc_ok  <- !is.na(d["Description"]) && !grepl("^What the package does", d["Description"], ignore.case = TRUE)
  lic_ok   <- !is.na(d["License"])     && grepl("MIT", d["License"])
  dep_ok   <- isTRUE(grepl("R\\s*\\(>=\\s*4\\.3\\)", d["Depends"] %||% "", perl = TRUE))
  urls_ok  <- !is.na(d["URL"]) && nzchar(d["URL"]) && !is.na(d["BugReports"]) && nzchar(d["BugReports"])
  ttest_ok <- !is.na(d["Config/testthat/edition"]) && grepl("\\b3\\b", d["Config/testthat/edition"])
  
  findings[[length(findings)+1]] <- add("DESCRIPTION Title ok", title_ok,  "Set Title via desc::desc_set()")
  findings[[length(findings)+1]] <- add("DESCRIPTION Description ok", desc_ok, "Set Description via desc::desc_set()")
  findings[[length(findings)+1]] <- add("DESCRIPTION License MIT", lic_ok, "Run usethis::use_mit_license('Zobaer Ahmed')")
  findings[[length(findings)+1]] <- add("DESCRIPTION Depends: R (>= 4.3)", dep_ok, "Ensure Depends includes R (>= 4.3)")
  findings[[length(findings)+1]] <- add("DESCRIPTION URLs set", urls_ok, "Set URL and BugReports")
  findings[[length(findings)+1]] <- add("Testthat edition 3", ttest_ok, "Run usethis::use_testthat(edition = 3)")
  
  # Ensure baseline Imports are present
  need_imports <- c("yaml","cli","tibble","shiny","bslib","htmltools","DBI","duckdb","arrow")
  imports_ok <- TRUE
  if (requireNamespace("desc", quietly = TRUE)) {
    im <- tryCatch(desc::desc_get_deps(), error = function(e) data.frame())
    if (nrow(im)) {
      have <- im$package[im$type == "Imports"]
      imports_ok <- all(need_imports %in% have)
    }
  }
  findings[[length(findings)+1]] <- add("DESCRIPTION Imports contain core pkgs", imports_ok,
                                        paste0("Add missing: ", paste(setdiff(need_imports, if (exists("have")) have else character()), collapse=", ")))
  
  # --- Package doc scaffold ---
  zzz_ok <- file.exists("R/zzz.R")
  findings[[length(findings)+1]] <- add("R/zzz.R present", zzz_ok, "Create minimal package doc in R/zzz.R")
  
  # --- NAMESPACE exports and Rd topics for public API ---
  ns_ok <- man_ok <- TRUE
  ns_lines <- if (file.exists("NAMESPACE")) tryCatch(readLines("NAMESPACE", warn = FALSE), error = function(e) character()) else character()
  exported <- function(fn) any(grepl(sprintf("^\\s*export\\(%s\\)\\s*$", fn), ns_lines))
  exp_vec <- c(
    build_static    = exported("build_static"),
    build_shiny     = exported("build_shiny"),
    build_shinylive = exported("build_shinylive"),
    build_quarto    = exported("build_quarto")
  )
  ns_ok <- all(unlist(exp_vec))
  findings[[length(findings)+1]] <- add("NAMESPACE exports build_*", ns_ok,
                                        "Add @export to roxygen blocks, then run devtools::document()")
  
  man_vec <- c(
    build_static    = file.exists("man/build_static.Rd"),
    build_shiny     = file.exists("man/build_shiny.Rd"),
    build_shinylive = file.exists("man/build_shinylive.Rd"),
    build_quarto    = file.exists("man/build_quarto.Rd")
  )
  man_ok <- all(man_vec)
  findings[[length(findings)+1]] <- add("man/ Rd topics for build_* exist", man_ok,
                                        "Run devtools::document() after adding roxygen blocks")
  
  # --- pkgdown config + reference index ---
  yml_ok <- file.exists("_pkgdown.yml")
  findings[[length(findings)+1]] <- add("_pkgdown.yml present", yml_ok, "Create _pkgdown.yml")
  
  ref_ok <- FALSE
  if (yml_ok) {
    # Prefer YAML parse, fall back to text search
    have_yaml <- requireNamespace("yaml", quietly = TRUE)
    if (have_yaml) {
      cfg <- tryCatch(yaml::read_yaml("_pkgdown.yml"), error = function(e) NULL)
      if (!is.null(cfg) && !is.null(cfg$reference)) {
        # Find a section titled "Build" that lists our topics
        secs <- cfg$reference
        has_build <- FALSE
        needs <- c("build_static","build_shiny","build_shinylive","build_quarto")
        for (s in secs) {
          title <- s$title %||% ""
          cont  <- unlist(s$contents %||% list())
          if (identical(title, "Build") && all(needs %in% cont)) {
            has_build <- TRUE
            break
          }
        }
        ref_ok <- has_build
      }
    } else {
      # crude fallback: look for all four topics in the file and the word "Build"
      txt <- paste0(readLines("_pkgdown.yml", warn = FALSE), collapse = "\n")
      ref_ok <- all(grepl("build_static|build_shiny|build_shinylive|build_quarto", txt)) && grepl("Build", txt)
    }
  }
  findings[[length(findings)+1]] <- add("pkgdown reference lists build_*", ref_ok,
                                        "Run scripts/task3_fix_pkgdown_reference.R")
  
  # --- built site present (site/ or docs/) ---
  site_ok <- file.exists("site/index.html") || file.exists("docs/index.html")
  findings[[length(findings)+1]] <- add("pkgdown site built (site/ or docs/)", site_ok,
                                        "Run scripts/task3_install_and_build_pkgdown.R")
  
  # --- pkgdown workflow present ---
  ci_ok <- file.exists(".github/workflows/pkgdown.yaml") || file.exists(".github/workflows/pkgdown.yml")
  findings[[length(findings)+1]] <- add("GitHub Actions pkgdown workflow present", ci_ok,
                                        "Run usethis::use_pkgdown_github_pages()")
  
  # Print report
  cat("\n=== Zashboard Task 3 Check ===\n")
  for (x in findings) {
    cat(sprintf("%s %s%s\n",
                if (x$pass) "✅" else "❌",
                x$name,
                if (!x$pass && nzchar(x$note)) paste0(" — FIX: ", x$note) else ""))
  }
  all_ok <- all(vapply(findings, `[[`, logical(1), "pass"))
  cat("\nSummary: ", if (all_ok) "✅ All Task 3 checks passed." else "❌ Some checks failed. See FIX hints above.", "\n", sep = "")
  invisible(all_ok)
}

# tiny base-R helper to avoid rlang dependency
`%||%` <- function(x, y) if (is.null(x) || length(x) == 0) y else x

# Run immediately when sourced
check_task3()
