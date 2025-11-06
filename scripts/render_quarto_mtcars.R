# scripts/render_quarto_mtcars.R

# 1) Deterministic path for the Quarto project
qdir <- file.path(tempdir(), "zash-mtcars-quarto")

# 2) (Re)generate the project there so we know it exists
spec <- system.file("examples/mtcars/mtcars.yml",
                    package = "zashboard", mustWork = TRUE)
zashboard::build_quarto(spec, out_dir = qdir, overwrite = TRUE)

# 3) Render the Quarto project (requires Quarto CLI installed)
quarto::quarto_render(qdir)

# 4) Open the built site
idx <- file.path(qdir, "_site", "index.html")
message("Opening: ", idx)
browseURL(idx)
