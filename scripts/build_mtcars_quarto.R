# Build a Quarto project for the built-in mtcars example.
# If Quarto CLI is installed, also render to HTML.

resolve_spec <- function() {
  p <- tryCatch(system.file("examples/mtcars/mtcars.yml",
                            package = "zashboard", mustWork = TRUE),
                error = function(e) "")
  if (!nzchar(p) || !file.exists(p)) {
    cand <- file.path("inst", "examples", "mtcars", "mtcars.yml")
    if (file.exists(cand)) p <- normalizePath(cand, winslash = "/", mustWork = TRUE)
  }
  if (!nzchar(p) || !file.exists(p)) {
    stop("Couldn't find mtcars.yml in installed package or source tree.")
  }
  p
}

spec_path <- resolve_spec()
out_dir <- file.path(tempdir(), "zash-mtcars-quarto")

res <- zashboard::build_quarto(spec_path, out_dir = out_dir, overwrite = TRUE)
cat("Quarto project created at:\n  ", out_dir, "\n")

can_render <- FALSE
if (requireNamespace("quarto", quietly = TRUE)) {
  can_render <- isTRUE(tryCatch(quarto::quarto_is_installed(), error = function(e) FALSE))
}
if (can_render) {
  cat("Rendering Quarto site…\n")
  quarto::quarto_render(out_dir, quiet = TRUE)
  cat("Rendered HTML:\n  ", file.path(out_dir, "_site", "index.html"), "\n")
} else {
  cat("Quarto CLI not found; open:\n  ",
      file.path(out_dir, "_quarto.yml"), "\n  ",
      file.path(out_dir, "index.qmd"), "\n", sep = "")
}
