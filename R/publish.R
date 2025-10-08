# Publisher helpers (stubs)
# Upload to object storage, set cache control, keep last N versions

zash_publish <- function(src_dir, provider = c('r2','s3','azure'), ...) {
  provider <- match.arg(provider)
  message(sprintf('Publishing %s to provider %s (stub)', src_dir, provider))
  invisible(TRUE)
}
