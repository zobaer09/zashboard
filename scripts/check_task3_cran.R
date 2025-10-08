# scripts/check_task3_cran.R
# CRAN-focused Task 3 checker: metadata, docs/exports, build ignore, pkgdown, and local R CMD check.

check_task3_cran <- function() {
  if (file.exists("renv/activate.R")) try(source("renv/activate.R"), silent = TRUE)
  
  add <- function(name, pass, note = "") list(name = name, pass = isTRUE(pass), note = note)
  findings <- list()
  
  # --- Helpers ---
  `%||%` <- function(x, y) if (is.null(x) || length(x) == 0) y else x
  have <- function(p) requireNamespace(p, quietly = TRUE)
  need <- function(pkgs) {
    miss <- pkgs[!vapply(pkgs, have, logical(1))]
    if (length(miss) && have("renv")) renv::install(miss)
  }
  
  # --- DESCRIPTION checks (strict for CRAN) ---
  desc_exists <- file.exists("DESCRIPTION")
  findings[[length(findings)+1]] <- add("DESCRIPTION present", desc_exists,
                                        "Run usethis::create_package('.')")
  
  pkg <- title <- descr <- license <- depends <- urls <- br <- ed3 <- enc <- NA_character_
  if (desc_exists) {
    need("desc")
    d <- tryCatch(desc::desc_get(c(
      "Package","Title","Description","License","Depends","URL","BugReports",
      "Config/testthat/edition","Encoding","Version","Maintainer"
    )), error = function(e) setNames(rep(NA_character_, 11),
                                     c("Package","Title","Description","License","Depends","URL","BugReports",
                                       "Config/testthat/edition","Encoding","Version","Maintainer")))
    
    pkg      <- d["Package"]; title <- d["Title"]; descr <- d["Description"]; license <- d["License"]
    depends  <- d["Depends"]; urls  <- d["URL"]; br    <- d["BugReports"]; ed3 <- d["Config/testthat/edition"]
    enc      <- d["Encoding"]; ver  <- d["Version"]; maint <- d["Maintainer"]
    
    # CRAN specifics
    title_ok <- !is.na(title) && nzchar(title) && !grepl("\\.$", title) # no trailing period
    descr_ok <- !is.na(descr) && nzchar(descr) &&
      !grepl(sprintf("^%s\\b", tolower(pkg)), tolower(descr)) &&
      !grepl("^this package\\b", tolower(descr))
    lic_ok   <- !is.na(license) && grepl("MIT", license)
    dep_ok   <- !is.na(depends) && grepl("R\\s*\\(>=\\s*4\\.3\\)", depends)
    urls_ok  <- !is.na(urls) && nzchar(urls) && !is.na(br) && nzchar(br)
    ed3_ok   <- !is.na(ed3) && grepl("\\b3\\b", ed3)
    enc_ok   <- !is.na(enc) && identical(enc, "UTF-8")
    
    # Authors/maintainer
    need("desc")
    authors <- tryCatch(desc::desc_get_authors(), error = function(e) NULL)
    has_cre <- FALSE
    if (!is.null(authors)) {
      roles <- unlist(lapply(authors, function(p) p$role %||% character()))
      has_cre <- any(grepl("^cre$", roles))
    } else {
      has_cre <- !is.na(maint) && nzchar(maint) # fallback
    }
    
    # Dev version warning for CRAN
    dev_version <- !is.na(ver) && grepl("\\.9000$", ver)
    
    findings <- append(findings, list(
      add("Title ok (no trailing '.')", title_ok, "Edit Title in DESCRIPTION; avoid trailing period"),
      add("Description ok (does not start with package name or 'This package')", descr_ok,
          "Rewrite Description to start with a sentence, not the package name"),
      add("License: MIT + file LICENSE", lic_ok, "Run usethis::use_mit_license('Zobaer Ahmed')"),
      add("Depends: R (>= 4.3)", dep_ok, "Set Depends: R (>= 4.3)"),
      add("URL & BugReports set", urls_ok, "Set URL and BugReports in DESCRIPTION"),
      add("Testthat edition 3 set", ed3_ok, "Run usethis::use_testthat(edition = 3)"),
      add("Encoding: UTF-8", enc_ok, "Set Encoding: UTF-8"),
      add("Authors include a 'cre' maintainer", has_cre, "Set Authors@R with a 'cre' maintainer via desc::desc_set_authors()"),
      add("Version is not a dev (.9000) for CRAN", !dev_version, "Bump to a release version like 0.1.0 before CRAN")
    ))
  }
  
  # --- .Rbuildignore for top-level extras (CRAN NOTE otherwise) ---
  rbi <- if (file.exists(".Rbuildignore")) paste(readLines(".Rbuildignore", warn = FALSE), collapse = "\n") else ""
  needed_ignores <- c(
    "^CHECKLIST\\.md$", "^SPEC\\.md$", "^CODE_OF_CONDUCT\\.md$", "^CONTRIBUTING\\.md$",
    "^SECURITY\\.md$", "^www$", "^zashboard-spec-starter\\.zip$", "^site$"
  )
  missing_ign <- needed_ignores[!vapply(needed_ignores, function(p) grepl(p, rbi), logical(1))]
  findings[[length(findings)+1]] <- add(".Rbuildignore covers non-package files", length(missing_ign) == 0,
                                        paste("Add to .Rbuildignore:", paste(missing_ign, collapse = ", ")))
  
  # --- Exports & Rd topics for public API ---
  ns_lines <- if (file.exists("NAMESPACE")) readLines("NAMESPACE", warn = FALSE) else character()
  exported <- function(fn) any(grepl(sprintf("^\\s*export\\(%s\\)\\s*$", fn), ns_lines))
  exp_ok <- all(c(exported("build_static"), exported("build_shiny"),
                  exported("build_shinylive"), exported("build_quarto")))
  findings[[length(findings)+1]] <- add("NAMESPACE exports build_*", exp_ok,
                                        "Add @export to roxygen and run devtools::document()")
  
  man_ok <- all(file.exists(file.path("man", sprintf("%s.Rd",
                                                     c("build_static","build_shiny","build_shinylive","build_quarto")))))
  findings[[length(findings)+1]] <- add("man/ Rd topics for build_* exist", man_ok,
                                        "Ensure roxygen blocks & run devtools::document()")
  
  # --- pkgdown config + reference (informational for CRAN but nice to have) ---
  yml_ok <- file.exists("_pkgdown.yml")
  findings[[length(findings)+1]] <- add("_pkgdown.yml present", yml_ok, "Create _pkgdown.yml")
  if (yml_ok && have("yaml")) {
    cfg <- tryCatch(yaml::read_yaml("_pkgdown.yml"), error = function(e) NULL)
    needs <- c("build_static","build_shiny","build_shinylive","build_quarto")
    ref_ok <- FALSE
    if (!is.null(cfg) && !is.null(cfg$reference)) {
      for (s in cfg$reference) {
        if (!is.null(s$title) && identical(s$title, "Build")) {
          cont <- unlist(s$contents %||% list())
          if (all(needs %in% cont)) ref_ok <- TRUE
        }
      }
    }
    findings[[length(findings)+1]] <- add("pkgdown reference lists build_*", ref_ok,
                                          "Restore Build section in _pkgdown.yml with all topics")
  }
  
  # --- Local R CMD check (as CRAN) ---
  need(c("rcmdcheck"))
  dir.create("ci-logs", showWarnings = FALSE)
  res <- rcmdcheck::rcmdcheck(args = c("--no-manual", "--as-cran"),
                              error_on = "never", check_dir = "ci-logs")
  warnings0 <- length(res$warnings) == 0
  errors0   <- length(res$errors) == 0
  findings[[length(findings)+1]] <- add("Local R CMD check: 0 errors", errors0, "Open ci-logs/zashboard.Rcheck/00check.log")
  findings[[length(findings)+1]] <- add("Local R CMD check: 0 warnings", warnings0,
                                        "Fix documentation/usage until warnings are gone")
  # NOTES are allowed pre-CRAN but we show the count
  notes_n <- length(res$notes)
  cat(sprintf("\nℹ Local R CMD check: %d NOTE(s)\n", notes_n))
  
  # --- Print report ---
  cat("\n=== Zashboard Task 3 CRAN Preflight ===\n")
  for (x in findings) {
    cat(sprintf("%s %s%s\n",
                if (x$pass) "✅" else "❌",
                x$name,
                if (!x$pass && nzchar(x$note)) paste0(" — FIX: ", x$note) else ""))
  }
  all_ok <- all(vapply(findings, `[[`, logical(1), "pass"))
  cat("\nSummary: ", if (all_ok) "✅ CRAN-oriented Task 3 checks passed." else "❌ Some checks failed. See FIX hints above.", "\n", sep = "")
  invisible(all_ok)
}

# Run immediately when sourced
check_task3_cran()
