#!/usr/bin/env Rscript
# Create a git tag and (optionally) a GitHub Release from NEWS.md.
# Defaults to DRY RUN: set ZASH_DRYRUN=0 to apply.

msg <- function(...) cat(sprintf(...), "\n")
die <- function(...) { msg(...); quit(status = 1L) }

# Activate renv if present
if (file.exists("renv/activate.R")) try(source("renv/activate.R"), silent = TRUE)

# --- Config via env vars -------------------------------------------------------
DRYRUN  <- identical(Sys.getenv("ZASH_DRYRUN", "1"), "1")
TAG     <- Sys.getenv("ZASH_TAG", "")          # optional override, e.g. v0.1.0
CREATE_GH_RELEASE <- identical(Sys.getenv("ZASH_GH_RELEASE", "0"), "1")  # off by default

# --- Read DESCRIPTION & NEWS ---------------------------------------------------
if (!file.exists("DESCRIPTION")) die("No DESCRIPTION found.")
if (!file.exists("NEWS.md"))    die("No NEWS.md found.")

if (!requireNamespace("desc", quietly = TRUE)) install.packages("desc")
desc <- desc::desc("DESCRIPTION")
ver  <- desc$get("Version")[[1]]
pkg  <- desc$get("Package")[[1]]

# Parse NEWS: prefer section matching DESCRIPTION version; else top section.
news_lines <- readLines("NEWS.md", warn = FALSE, encoding = "UTF-8")
hdr_rx  <- "^#\\s*([A-Za-z0-9._-]+)\\s+([0-9][^\\s]*)\\b.*$"
is_hdr  <- grepl(hdr_rx, news_lines)
hdr_idx <- which(is_hdr)
extract_section <- function(start_idx) {
  end_idx <- if (any(hdr_idx > start_idx)) min(hdr_idx[hdr_idx > start_idx]) - 1L else length(news_lines)
  block   <- news_lines[start_idx:end_idx]
  if (length(block) > 1L) paste(block[-1L], collapse = "\n") else ""
}
i_match <- NA_integer_
if (length(hdr_idx)) {
  hdr_info <- sub(hdr_rx, "\\2", news_lines[hdr_idx])
  i_match  <- hdr_idx[which(tolower(hdr_info) == tolower(ver))[1]]
}
if (is.na(i_match)) {
  body_md <- if (length(hdr_idx)) trimws(extract_section(hdr_idx[1])) else ""
  if (!nzchar(body_md)) body_md <- "(no release notes)"
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
msg("\n--- Release notes (from NEWS.md) ---\n%s\n", body_md)

# --- Tag locally (gert with fallback to system git) ----------------------------
create_tag <- function(tag_name, message) {
  # Try gert first
  ok <- FALSE
  if (requireNamespace("gert", quietly = TRUE)) {
    # correct signature: git_tag_create(name, ref="HEAD", message=NULL, repo=".")
    out <- try(gert::git_tag_create(tag_name, message = message), silent = TRUE)
    if (!inherits(out, "try-error")) ok <- TRUE
  }
  if (!ok) {
    # Fallback to system git (annotated tag)
    cmd <- sprintf('git tag -a %s -m "%s"', shQuote(tag_name), gsub('"', '\\"', message))
    sts <- system(cmd, ignore.stdout = TRUE, ignore.stderr = FALSE)
    ok <- (sts == 0L)
  }
  ok
}

if (!DRYRUN) {
  # Does it already exist?
  exists <- FALSE
  if (requireNamespace("gert", quietly = TRUE)) {
    tg <- try(gert::git_tag_list(), silent = TRUE)
    exists <- !inherits(tg, "try-error") && any(tg$name == tag_name)
  } else {
    # fallback check
    tags_raw <- suppressWarnings(system("git tag --list", intern = TRUE))
    exists <- length(tags_raw) && any(trimws(tags_raw) == tag_name)
  }
  
  if (exists) {
    msg("Tag '%s' already exists (skipping).", tag_name)
  } else {
    if (create_tag(tag_name, sprintf("%s %s", pkg, ver))) {
      msg("Created tag: %s", tag_name)
    } else {
      die("Failed to create tag using both gert and system git.")
    }
  }
}

# --- Optional GitHub Release ---------------------------------------------------
if (!DRYRUN && CREATE_GH_RELEASE) {
  # Only run if explicitly enabled
  if (!requireNamespace("gh", quietly = TRUE)) install.packages("gh")
  # detect repo
  parse_repo <- function() {
    # use git remote origin URL
    url <- suppressWarnings(system("git config --get remote.origin.url", intern = TRUE))
    if (!length(url)) return(NULL)
    url <- url[1]
    m <- regexec("github\\.com[/:]([^/]+)/([^/]+?)(?:\\.git)?$", url)
    r <- regmatches(url, m)[[1]]
    if (length(r) == 3) list(owner = r[2], repo = r[3]) else NULL
  }
  repo <- parse_repo()
  if (is.null(repo)) die("Cannot detect GitHub repo from 'origin' remote.")
  
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

# --- Show resulting tags -------------------------------------------------------
tags_after <- suppressWarnings(system("git tag --list", intern = TRUE))
msg("\nExisting tags:\n%s", if (length(tags_after)) paste(tags_after, collapse = "\n") else "<none>")
msg("\nDone. %s", if (DRYRUN) "This was a dry run (no changes made)." else "Applied.")
