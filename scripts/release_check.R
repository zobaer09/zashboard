#!/usr/bin/env Rscript
# Create a git tag and (optionally) a GitHub Release from NEWS.md.
# Defaults to DRY RUN: set ZASH_DRYRUN=0 to apply.

msg <- function(...) cat(sprintf(...), "\n")
die <- function(...) { msg(...); quit(status = 1L) }

# Activate renv if present
if (file.exists("renv/activate.R")) try(source("renv/activate.R"), silent = TRUE)

# --- Config via env vars -------------------------------------------------------
DRYRUN  <- identical(Sys.getenv("ZASH_DRYRUN", "1"), "1")
TAG     <- Sys.getenv("ZASH_TAG", "")      # optional override, e.g. v0.1.0
CREATE_GH_RELEASE <- identical(Sys.getenv("ZASH_GH_RELEASE", "0"), "1")  # off by default

# --- Read DESCRIPTION & NEWS ---------------------------------------------------
if (!file.exists("DESCRIPTION")) die("No DESCRIPTION found.")
if (!file.exists("NEWS.md"))    die("No NEWS.md found.")

if (!requireNamespace("desc", quietly = TRUE)) install.packages("desc")
desc <- desc::desc("DESCRIPTION")
ver  <- desc$get("Version")[[1]]
pkg  <- desc$get("Package")[[1]]

# Parse NEWS: prefer section that matches DESCRIPTION version;
# otherwise fall back to the top section and warn.
news_lines <- readLines("NEWS.md", warn = FALSE, encoding = "UTF-8")
# headers like: "# zashboard 0.1.0 (yyyy-mm-dd|unreleased)"
hdr_rx  <- "^#\\s*([A-Za-z0-9._-]+)\\s+([0-9][^\\s]*)\\b.*$"
is_hdr  <- grepl(hdr_rx, news_lines)
hdr_idx <- which(is_hdr)

extract_section <- function(start_idx) {
  stopifnot(length(start_idx) == 1)
  end_idx <- if (any(hdr_idx > start_idx)) min(hdr_idx[hdr_idx > start_idx]) - 1L else length(news_lines)
  block   <- news_lines[start_idx:end_idx]
  if (length(block) > 1) paste(block[-1], collapse = "\n") else ""
}

# Find header that matches DESCRIPTION version
i_match <- NA_integer_
if (length(hdr_idx)) {
  # capture version from each header
  hdr_info <- sub(hdr_rx, "\\2", news_lines[hdr_idx])
  i_match  <- hdr_idx[which(tolower(hdr_info) == tolower(ver))[1]]
}

if (is.na(i_match)) {
  # fall back to top section
  if (!length(hdr_idx)) {
    body_md <- "(no release notes)"
    top_ver <- NA_character_
  } else {
    i_top   <- hdr_idx[1]
    body_md <- trimws(extract_section(i_top))
    top_ver <- sub(hdr_rx, "\\2", news_lines[i_top])
    if (!nzchar(body_md)) body_md <- "(no release notes)"
    msg("Note: NEWS top version (%s) does not match DESCRIPTION (%s). Using top section as release notes.", top_ver, ver)
  }
} else {
  body_md <- trimws(extract_section(i_match))
  if (!nzchar(body_md)) body_md <- "(no release notes)"
}

tag_name <- if (nzchar(TAG)) TAG else paste0("v", ver)
msg("Package : %s", pkg)
msg("Version : %s", ver)
msg("Tag     : %s", tag_name)
msg("Dry-run : %s", DRYRUN)
msg("GH rel. : %s", CREATE_GH_RELEASE)

# --- Determine repo owner/name from origin url (for GH release) ---------------
parse_repo <- function() {
  if (!requireNamespace("gert", quietly = TRUE)) install.packages("gert")
  rem <- try(gert::git_remote_list(), silent = TRUE)
  if (inherits(rem, "try-error") || !nrow(rem)) return(NULL)
  url <- rem$url[rem$name == "origin"][1]
  if (!nzchar(url)) return(NULL)
  # https://github.com/owner/repo(.git)  OR  git@github.com:owner/repo.git
  m <- regexec("github\\.com[/:]([^/]+)/([^/]+?)(?:\\.git)?$", url)
  r <- regmatches(url, m)[[1]]
  if (length(r) == 3) list(owner = r[2], repo = r[3]) else NULL
}
repo <- parse_repo()

# --- Show plan ----------------------------------------------------------------
msg("\n--- Release notes (from NEWS.md) ---\n%s\n", body_md)

# --- Tag locally --------------------------------------------------------------
if (!DRYRUN) {
  if (!requireNamespace("gert", quietly = TRUE)) install.packages("gert")
  # create annotated tag if it doesn't already exist
  tags <- try(gert::git_tag_list(), silent = TRUE)
  exists <- !inherits(tags, "try-error") && any(tags$name == tag_name)
  if (exists) {
    msg("Tag '%s' already exists (skipping).", tag_name)
  } else {
    # NOTE: correct signature is git_tag_create(name, ref="HEAD", message=NULL, repo=".")
    gert::git_tag_create(tag_name, message = sprintf("%s %s", pkg, ver))
    msg("Created tag: %s", tag_name)
  }
}

# --- Optional: GitHub Release -------------------------------------------------
if (!DRYRUN && CREATE_GH_RELEASE) {
  if (is.null(repo)) die("Cannot detect GitHub repo from 'origin' remote.")
  if (!requireNamespace("gh", quietly = TRUE)) install.packages("gh")
  
  tok <- Sys.getenv("GITHUB_TOKEN", Sys.getenv("GH_TOKEN", ""))
  if (!nzchar(tok)) die("No GitHub token found in GITHUB_TOKEN/GH_TOKEN. Set it and retry.")
  
  msg("Creating GitHub release %s/%s @ %s ...", repo$owner, repo$repo, tag_name)
  gh::gh("POST /repos/{owner}/{repo}/releases",
         owner = repo$owner, repo = repo$repo,
         tag_name = tag_name,
         name = sprintf("%s %s", pkg, ver),
         body = body_md,
         draft = FALSE, prerelease = FALSE)
  msg("GitHub release created.")
}

msg("\nDone. %s", if (DRYRUN) "This was a dry run (no changes made)." else "Applied.")
