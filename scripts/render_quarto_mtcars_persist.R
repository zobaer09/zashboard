# scripts/render_quarto_mtcars_persist.R

qdir <- file.path("examples_out", "mtcars-quarto")   # persistent folder in repo
dir.create(qdir, recursive = TRUE, showWarnings = FALSE)

spec <- system.file("examples/mtcars/mtcars.yml",
                    package = "zashboard", mustWork = TRUE)

# (re)generate the Quarto project
zashboard::build_quarto(spec, out_dir = qdir, overwrite = TRUE)

# render the site (requires Quarto CLI)
stopifnot(quarto::quarto_available())
quarto::quarto_render(qdir)

# open the built site
idx <- normalizePath(file.path(qdir, "_site", "index.html"),
                     winslash = "\\", mustWork = TRUE)
message("Opening: ", idx)
if (.Platform$OS.type == "windows") shell.exec(idx) else browseURL(idx)
