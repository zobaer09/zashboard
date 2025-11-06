# scripts/examples_check_outputs.R
ok <- function(p) file.exists(p) && !dir.exists(p)
paths <- list(
  static   = file.path("examples_out","mtcars-static","index.html"),
  shinylive= file.path("examples_out","mtcars-shinylive","index.html"),
  quarto_yml = file.path("examples_out","mtcars-quarto","_quarto.yml"),
  quarto_qmd = file.path("examples_out","mtcars-quarto","index.qmd")
)
print(data.frame(target = names(paths), exists = vapply(paths, ok, logical(1))))
