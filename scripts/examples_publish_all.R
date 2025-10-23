# scripts/examples_publish_all.R
# Build & publish STATIC + SHINYLIVE + QUARTO to docs/examples/*/*

if (file.exists("renv/activate.R")) source("renv/activate.R")

# ---- helpers ---------------------------------------------------------------

copy_dir_contents <- function(from_dir, dest_dir) {
  if (!dir.exists(from_dir)) stop("Source directory does not exist: ", from_dir)
  
  # clean destination and create root
  if (dir.exists(dest_dir)) unlink(dest_dir, recursive = TRUE, force = TRUE)
  dir.create(dest_dir, recursive = TRUE, showWarnings = FALSE)
  
  # Fast path if fs is available
  if (requireNamespace("fs", quietly = TRUE)) {
    fs::dir_copy(from_dir, dest_dir, overwrite = TRUE)
    return(invisible(dest_dir))
  }
  
  # Base R fallback: create all subdirs first, then copy files
  root <- normalizePath(from_dir, winslash = "/", mustWork = TRUE)
  paths <- list.files(root, recursive = TRUE, all.files = TRUE,
                      full.names = TRUE, no.. = TRUE)
  # split dirs vs files
  dirs  <- paths[dir.exists(paths)]
  files <- paths[!dir.exists(paths)]
  
  # helper to make relative paths
  esc <- function(x) gsub("([.|()\\^{}+$*?]|\\[|\\])", "\\\\\\1", x)
  rel  <- function(x) sub(paste0("^", esc(root), "/?"), "", normalizePath(x, winslash = "/"))
  
  # create directories (ensure parents exist)
  rel_dirs <- rel(dirs)
  rel_dirs <- rel_dirs[nzchar(rel_dirs)]
  if (length(rel_dirs)) {
    for (d in unique(rel_dirs)) dir.create(file.path(dest_dir, d), recursive = TRUE, showWarnings = FALSE)
  }
  
  # copy files into place
  rel_files <- rel(files)
  ok <- if (length(files)) file.copy(from = files, to = file.path(dest_dir, rel_files),
                                     overwrite = TRUE, copy.mode = TRUE) else logical()
  if (length(files) && !all(ok)) {
    bad <- paste(rel_files[!ok], collapse = ", ")
    stop("Failed to copy some files from ", from_dir, " to ", dest_dir, ": ", bad)
  }
  
  invisible(dest_dir)
}


build_four <- function(spec_path, name) {
  base <- file.path(getwd(), "examples_out", name)
  dir.create(base, recursive = TRUE, showWarnings = FALSE)
  
  static_dir    <- zashboard::build_static   (spec_path, out_dir = file.path(base, "static"),    overwrite = TRUE)
  shinylive_dir <- zashboard::build_shinylive(spec_path, out_dir = file.path(base, "shinylive"), overwrite = TRUE)
  quarto_dir    <- zashboard::build_quarto   (spec_path, out_dir = file.path(base, "quarto"),    overwrite = TRUE, render = FALSE)
  shiny_app     <- zashboard::build_shiny    (spec_path)
  
  list(static_dir = static_dir,
       shinylive_dir = shinylive_dir,
       quarto_dir = quarto_dir,
       shiny_app = shiny_app)
}

render_quarto_site <- function(quarto_dir) {
  # quarto_dir contains _quarto.yml & index.qmd
  if (!nzchar(quarto::quarto_path())) {
    warning("Quarto CLI not available; skipping render for: ", quarto_dir)
    return(invisible(NULL))
  }
  quarto::quarto_render(quarto_dir, quiet = TRUE)
  file.path(quarto_dir, "_site")
}

publish_one <- function(b, name) {
  # 1) static
  copy_dir_contents(b$static_dir, file.path("docs", "examples", name, "static"))
  
  # 2) shinylive (already complete site)
  copy_dir_contents(b$shinylive_dir, file.path("docs", "examples", name, "shinylive"))
  
  # 3) quarto (_site after render)
  site <- render_quarto_site(b$quarto_dir)
  if (!is.null(site) && dir.exists(site)) {
    copy_dir_contents(site, file.path("docs", "examples", name, "quarto"))
  }
}

# ---- build + publish -------------------------------------------------------

b_iris <- build_four("inst/examples/iris/iris.yml",               "iris")
b_air  <- build_four("inst/examples/airquality/airquality.yml",   "airquality")
b_tg   <- build_four("inst/examples/toothgrowth/toothgrowth.yml", "toothgrowth")
b_co2  <- build_four("inst/examples/co2/co2.yml",                 "co2")

publish_one(b_iris, "iris")
publish_one(b_air,  "airquality")
publish_one(b_tg,   "toothgrowth")
publish_one(b_co2,  "co2")

# write an index under docs/examples
base <- "https://zobaer09.github.io/zashboard/examples"
index <- c(
  "<!doctype html><meta charset='utf-8'>",
  "<body style='font-family:system-ui,Segoe UI,Arial;margin:24px'>",
  "<h1>Zashboard demos</h1>",
  "<p>Each demo is published in three flavors: static HTML, Shinylive (client-side Shiny), and Quarto.</p>",
  "<ul>",
  sprintf("<li>Iris — <a href='%s/iris/static/'>static</a> · <a href='%s/iris/shinylive/'>shinylive</a> · <a href='%s/iris/quarto/'>quarto</a></li>", base, base, base),
  sprintf("<li>Airquality — <a href='%s/airquality/static/'>static</a> · <a href='%s/airquality/shinylive/'>shinylive</a> · <a href='%s/airquality/quarto/'>quarto</a></li>", base, base, base),
  sprintf("<li>ToothGrowth — <a href='%s/toothgrowth/static/'>static</a> · <a href='%s/toothgrowth/shinylive/'>shinylive</a> · <a href='%s/toothgrowth/quarto/'>quarto</a></li>", base, base, base),
  sprintf("<li>CO2 — <a href='%s/co2/static/'>static</a> · <a href='%s/co2/shinylive/'>shinylive</a> · <a href='%s/co2/quarto/'>quarto</a></li>", base, base, base),
  "</ul>",
  "<p>Generated by <code>scripts/examples_publish_all.R</code></p>",
  "</body>"
)
dir.create(file.path("docs","examples"), recursive = TRUE, showWarnings = FALSE)
writeLines(index, file.path("docs","examples","index.html"))

# nojekyll so assets load on GH Pages
writeLines("", file.path("docs", ".nojekyll"))

message("All demos published under docs/examples/.")
