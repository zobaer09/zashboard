# Validator stubs (keep your existing behavior)
zash_validate_spec <- function(spec) {
  # You can expand this later; for now we always say it's ok
  list(ok = TRUE, messages = character())
}

#' Validate and normalize a spec (path or list)
#'
#' This function accepts either a file path (YAML) or an already-parsed list.
#' It normalizes chart keys (e.g., quoted 'y') and runs a basic validator.
#'
#' @param spec Path to YAML, or a spec list
#' @return A normalized spec list
#' @export
zashboard_read_validate <- function(spec) {
  sp <- if (is.character(spec)) zashboard_read_spec(spec) else spec
  
  # If charts came from a list, still make sure odd keys are normalized
  if (is.list(sp)) {
    if (is.null(sp$charts)) sp$charts <- list()
    if (is.null(sp$datasets)) sp$datasets <- list()
    sp <- .zash_normalize_chart_keys(sp)
  } else {
    stop("`spec` must be a YAML path or a list.", call. = FALSE)
  }
  
  # Run your stub validator (rename later if you improve it)
  v <- zash_validate_spec(sp)
  if (is.list(v) && isFALSE(v$ok)) {
    msg <- paste(v$messages, collapse = "\n- ")
    stop("Spec validation failed:\n- ", msg, call. = FALSE)
  }
  
  sp
}
