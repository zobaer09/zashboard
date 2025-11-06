#' Read a Zashboard spec (YAML) from disk
#'
#' @param path Path to a YAML file
#' @return A list representing the spec
#' @export
zashboard_read_spec <- function(path) {
  if (!is.character(path) || length(path) != 1L) {
    stop("`path` must be a single file path (character scalar).", call. = FALSE)
  }
  if (!file.exists(path)) stop("Spec file not found: ", path, call. = FALSE)
  sp <- yaml::read_yaml(path)
  
  # Ensure top-level structures are what we expect
  if (is.null(sp$charts)) sp$charts <- list()
  if (is.null(sp$datasets)) sp$datasets <- list()
  
  # Normalize odd chart keys like `'y': ...` or `` `y`: ... ``
  sp <- .zash_normalize_chart_keys(sp)
  
  sp
}

# Internal helper: normalize funny chart keys
.zash_normalize_chart_keys <- function(sp) {
  if (!is.list(sp$charts)) return(sp)
  for (i in seq_along(sp$charts)) {
    ch <- sp$charts[[i]]
    
    # If y is missing, look for any key that becomes "y" after stripping quotes/backticks
    if (is.null(ch$y)) {
      cand <- Filter(function(nm) {
        gsub("[`'\"]", "", trimws(nm)) == "y"
      }, names(ch))
      if (length(cand)) ch$y <- ch[[cand[[1]]]]
    }
    
    # Coerce id/type/dataset/x/y to simple character if present
    for (nm in c("id","type","dataset","x","y","title","metric","fmt")) {
      if (!is.null(ch[[nm]]) && !is.character(ch[[nm]])) {
        ch[[nm]] <- as.character(ch[[nm]])
      }
    }
    
    sp$charts[[i]] <- ch
  }
  sp
}
