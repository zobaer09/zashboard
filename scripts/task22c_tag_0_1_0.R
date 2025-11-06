# Task 22c: create tag v0.1.0 from NEWS.md; optionally push to GitHub.
# Env:
#   ZASH_DRYRUN=1 (default)  -> print what would happen
#   ZASH_DRYRUN=0            -> create tag
#   ZASH_PUSH=1              -> push the tag to origin

if (file.exists("renv/activate.R")) try(source("renv/activate.R"), silent = TRUE)
dry_run <- identical(Sys.getenv("ZASH_DRYRUN", "1"), "1")
do_push <- identical(Sys.getenv("ZASH_PUSH", "0"), "1")
tag      <- "v0.1.0"

msg <- function(...) cat(sprintf(...), "\n")

stopifnot(file.exists("DESCRIPTION"), file.exists("NEWS.md"))
if (!requireNamespace("gert", quietly = TRUE)) install.packages("gert")

# 1) Read version + release notes
desc <- read.dcf("DESCRIPTION")
ver  <- as.character(desc[1, "Version"])
news <- readLines("NEWS.md", warn = FALSE, encoding = "UTF-8")

start <- grep("^#\\s*zashboard\\s+0\\.1\\.0\\b", news, ignore.case = TRUE)
stop  <- c(grep("^#\\s*zashboard\\s+\\d", news)[-1], length(news) + 1)
stop  <- stop[min(which(stop > start))] - 1
if (!length(start)) stop("Could not find 'zashboard 0.1.0' header in NEWS.md.")
notes <- trimws(paste(news[start:stop], collapse = "\n"))

msg("Package : zashboard")
msg("Version : %s", ver)
msg("Tag     : %s", tag)
msg("Dry-run : %s", dry_run)
msg("Push    : %s", do_push)
cat("\n--- Tag message (from NEWS.md) ---\n")
cat(notes, "\n")
cat("-----------------------------------\n\n")

# 2) Check existing tags
existing <- vapply(gert::git_tag_list()$name, as.character, "")
if (tag %in% existing) {
  msg("Tag %s already exists.", tag)
  if (!do_push) quit(save = "no")
}

# 3) Create tag (annotated)
if (!dry_run && !(tag %in% existing)) {
  gert::git_tag_create(name = tag, ref = "HEAD", message = notes)
  msg("Created tag: %s", tag)
} else if (dry_run && !(tag %in% existing)) {
  msg("(dry-run) Would create tag: %s", tag)
}

# 4) Optional push to origin
if (do_push) {
  # Push only this tag to avoid pushing any others.
  system2("git", c("push", "origin", tag), stdout = TRUE, stderr = TRUE)
  msg("Pushed tag %s to origin.", tag)
}

msg("Done.")
