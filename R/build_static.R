#' Build a static HTML dashboard from a spec
#' @param spec Path to YAML spec (or spec list)
#' @param out_dir Output directory
#' @param overwrite Overwrite output directory if it exists
#' @param title Optional page title override
#' @export
build_static <- function(spec,
                         out_dir = file.path(tempdir(), "zashboard-static"),
                         overwrite = TRUE,
                         title = NULL,
                         ...) {
  `%||%` <- function(a,b) if (is.null(a)||length(a)==0) b else a
  
  # read + validate
  sp <- if (is.list(spec)) spec else zashboard_read_validate(spec)
  page_title <- title %||% sp$title %||% "Zashboard"
  
  out_dir <- normalizePath(out_dir, winslash = "/", mustWork = FALSE)
  if (dir.exists(out_dir) && overwrite) unlink(out_dir, recursive = TRUE, force = TRUE)
  dir.create(file.path(out_dir, "assets"), recursive = TRUE, showWarnings = FALSE)
  
  # resolve r_data datasets
  get_ds <- function(d) {
    stopifnot(identical(d$type, "r_data"))
    getExportedValue(d$package, d$name)
  }
  datasets <- lapply(sp$datasets, get_ds)
  
  png_plot <- function(file, expr, w=960, h=540) {
    grDevices::png(file, width=w, height=h, res=96, bg="white")
    on.exit(grDevices::dev.off(), add = TRUE)
    eval.parent(substitute(expr))
  }
  
  agg_fun <- function(name) {
    nm <- tolower(name)
    switch(nm,
           mean   = function(v) mean(v,   na.rm = TRUE),
           sum    = function(v) sum(v,    na.rm = TRUE),
           median = function(v) median(v, na.rm = TRUE),
           max    = function(v) max(v,    na.rm = TRUE),
           min    = function(v) min(v,    na.rm = TRUE),
           sd     = function(v) sd(v,     na.rm = TRUE),
           var    = function(v) var(v,    na.rm = TRUE),
           n      = function(v) sum(is.finite(v)),
           length = function(v) length(v),
           function(v) mean(v, na.rm = TRUE)
    )
  }
  
  parse_y <- function(y, ds) {
    # returns list(col, fun, label)
    if (is.null(y)) return(list(col=NULL, fun=NULL, label=NULL))
    if (grepl("^[A-Za-z]+\\([^()]+\\)$", y)) {
      fun_name <- sub("^([A-Za-z]+)\\(([^)]+)\\)$", "\\1", y)
      col_name <- sub("^[A-Za-z]+\\(([^)]+)\\)$", "\\1", y)
      list(col = ds[[col_name]], fun = agg_fun(fun_name), label = y)
    } else {
      list(col = ds[[as.character(y)]], fun = agg_fun("mean"), label = as.character(y))
    }
  }
  
  kpi_card <- function(label, value, fmt="%.0f"){
    sprintf(
      '<div style="display:inline-block;border:1px solid #ddd;border-radius:8px;padding:16px 20px;margin:8px 0;">
         <div style="font-size:14px;color:#666;">%s</div>
         <div style="font-size:36px;font-weight:700;">%s</div>
       </div>',
      label, sprintf(fmt, value)
    )
  }
  
  html <- c(
    '<!doctype html><meta charset="utf-8">',
    '<body style="font-family:system-ui,Segoe UI,Arial;margin:24px">',
    sprintf('<h1>%s — Static</h1>', page_title)
  )
  
  for (ch in sp$charts) {
    id <- ch$id; typ <- ch$type; ds <- datasets[[ch$dataset]]
    
    if (identical(typ, "bar")) {
      stopifnot(!is.null(ch$x), !is.null(ch$y))
      parts <- parse_y(ch$y, ds)
      xvec  <- ds[[as.character(ch$x)]]
      yvec  <- parts$col
      keep <- is.finite(xvec) & is.finite(yvec)
      if (length(keep) == length(xvec) && length(keep) == length(yvec)) {
        xvec <- xvec[keep]; yvec <- yvec[keep]
      }
      if (!is.numeric(yvec)) yvec <- suppressWarnings(as.numeric(yvec))
      vals <- try(tapply(yvec, INDEX = xvec, FUN = parts$fun), silent = TRUE)
      
      out_img <- file.path(out_dir, "assets", paste0(id, ".png"))
      png_plot(out_img, {
        if (inherits(vals, "try-error") || !length(vals) || all(!is.finite(vals))) {
          plot.new(); text(0.5,0.5,"No data to plot", cex=1.2)
        } else {
          vals <- vals[is.finite(vals)]
          barplot(vals, main = ch$title %||% id,
                  xlab = as.character(ch$x), ylab = parts$label %||% ch$y)
        }
      })
      html <- c(html,
                sprintf('<h2>%s</h2>', ch$title %||% id),
                sprintf('<img src="assets/%s.png" alt="%s" style="max-width:100%%;height:auto;">', id, ch$title %||% id)
      )
      
    } else if (identical(typ, "scatter")) {
      stopifnot(!is.null(ch$x), !is.null(ch$y))
      x <- ds[[as.character(ch$x)]]
      y <- ds[[as.character(ch$y)]]
      keep <- is.finite(x) & is.finite(y)
      x <- x[keep]; y <- y[keep]
      
      out_img <- file.path(out_dir, "assets", paste0(id, ".png"))
      png_plot(out_img, {
        if (!length(x) || !length(y)) { plot.new(); text(0.5,0.5,"No data to plot", cex=1.2) }
        else plot(x, y, pch=19,
                  main = ch$title %||% id,
                  xlab = as.character(ch$x), ylab = as.character(ch$y))
      })
      html <- c(html,
                sprintf('<h2>%s</h2>', ch$title %||% id),
                sprintf('<img src="assets/%s.png" alt="%s" style="max-width:100%%;height:auto;">', id, ch$title %||% id)
      )
      
    } else if (identical(typ, "kpi")) {
      val <- NA_real_
      if (!is.null(ch$metric) && ch$metric == "n()") {
        val <- nrow(ds)
      } else if (!is.null(ch$metric) && grepl("^mean\\(([^)]+)\\)$", ch$metric)) {
        col <- sub("^mean\\(([^)]+)\\)$","\\1", ch$metric)
        val <- mean(ds[[col]], na.rm = TRUE)
      }
      html <- c(html, sprintf('<h2>%s</h2>', ch$title %||% id),
                kpi_card(ch$title %||% id, val, ch$fmt %||% "%.0f"))
      
    } else {
      html <- c(html, sprintf('<h2>%s</h2>', ch$title %||% id),
                '<p>Preview table (chart type not supported in this static preview).</p>')
      tbl <- utils::head(ds, 12)
      html <- c(html, paste(capture.output(print(tbl)), collapse = "<br>"))
    }
  }
  
  html <- c(html, '<p>Generated by zashboard::build_static()</p>', '</body>')
  writeLines(html, file.path(out_dir, "index.html"))
  out_dir
}
