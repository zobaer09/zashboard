#' If the cli package is installed, uses cli::cli_abort with bullets; otherwise
#' falls back to stop() with a joined message.

#' @param errors Character vector of error messages.
#' @param prefix Prefix line for the error header.
#' @keywords internal
zashboard_abort <- function(errors, prefix = "Validation failed") {
  errs <- unique(as.character(errors))
  if (requireNamespace("cli", quietly = TRUE)) {
    cli::cli_abort(c(prefix, setNames(errs, rep("x", length(errs)))))
  } else {
    msg <- paste0(prefix, ":\n", paste0(" - ", errs, collapse = "\n"))
    stop(msg, call. = FALSE)
  }
}
