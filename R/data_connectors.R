#' Connect to a DuckDB database
#'
#' Opens a DuckDB connection using \pkg{DBI}/\pkg{duckdb}. Uses an in-memory
#' database by default, suitable for local analytics and caching.
#'
#' @param dbfile Path to a DuckDB file, or \code{":memory:"} (default).
#' @param read_only Logical; open database read-only (default \code{FALSE}).
#' @return A list of class \code{"zashboard_conn"} with fields:
#'   \code{type}, \code{handle}, and a \code{disconnect} function.
#' @export
zashboard_connect_duckdb <- function(dbfile = ":memory:", read_only = FALSE) {
  if (!requireNamespace("DBI", quietly = TRUE) || !requireNamespace("duckdb", quietly = TRUE)) {
    stop("Packages 'DBI' and 'duckdb' are required for DuckDB. Install them to use this connector.", call. = FALSE)
  }
  # duckdb::duckdb() accepts ":memory:" or a filesystem path directly
  drv <- duckdb::duckdb(dbdir = dbfile, read_only = read_only)
  con <- DBI::dbConnect(drv)
  structure(list(
    type = "duckdb",
    handle = con,
    disconnect = function() {
      try(DBI::dbDisconnect(con, shutdown = TRUE), silent = TRUE)
      invisible(TRUE)
    }
  ), class = "zashboard_conn")
}


#' Connect to an Arrow dataset
#'
#' Opens a dataset using \pkg{arrow}. Works with a directory or a single file
#' (e.g., Parquet). Use \code{zashboard_execute_collect()} to retrieve data.
#'
#' @param path Directory or file containing the dataset.
#' @return A zashboard connection object.
#' @export
zashboard_connect_arrow <- function(path) {
  if (!requireNamespace("arrow", quietly = TRUE)) {
    stop("Package 'arrow' is required for Arrow datasets. Install it to use this connector.", call. = FALSE)
  }
  if (!file.exists(path)) stop("Arrow path not found: ", path, call. = FALSE)
  
  is_file <- !dir.exists(path)
  ds <- if (is_file) NULL else arrow::open_dataset(path)
  
  structure(list(
    type = "arrow",
    handle = ds,                                      # Dataset or NULL for single-file
    path = normalizePath(path, winslash = "/", mustWork = TRUE),
    is_file = is_file,
    disconnect = function() invisible(TRUE)
  ), class = "zashboard_conn")
}

#' Connect to Microsoft SQL Server (stub)
#'
#' Uses \pkg{DBI}/\pkg{odbc}. This function validates inputs and errors with a
#' clear message if \pkg{odbc} is not installed or connection details are missing.
#'
#' @param dsn Optional ODBC DSN name.
#' @param connection_string Optional full connection string (e.g., "Driver={ODBC Driver 18 for SQL Server};Server=...").
#' @param ... Additional fields passed to \code{DBI::dbConnect()} (e.g., \code{UID}, \code{PWD}, \code{Database}).
#' @return A zashboard connection object if successful.
#' @export
zashboard_connect_mssql <- function(dsn = NULL, connection_string = NULL, ...) {
  if (!requireNamespace("DBI", quietly = TRUE) || !requireNamespace("odbc", quietly = TRUE)) {
    stop("Packages 'DBI' and 'odbc' are required for SQL Server. Install them to use this connector.", call. = FALSE)
  }
  if (is.null(dsn) && is.null(connection_string)) {
    stop("Provide either a DSN or a full ODBC connection string to connect to SQL Server.", call. = FALSE)
  }
  # We do not actually attempt a network connection in this skeleton.
  stop("MSSQL connector stub: connection not attempted in tests. Provide DSN/connection_string in real usage.", call. = FALSE)
}

#' Execute a SQL query on a connector (DuckDB/MSSQL)
#'
#' @param conn A zashboard connection object from \code{zashboard_connect_*()}.
#' @param sql A single SQL string.
#' @return A data frame with results.
#' @export
zashboard_execute_sql <- function(conn, sql) {
  stopifnot(inherits(conn, "zashboard_conn"), is.character(sql), length(sql) == 1L)
  if (identical(conn$type, "duckdb")) {
    if (!requireNamespace("DBI", quietly = TRUE)) stop("Package 'DBI' is required.", call. = FALSE)
    return(DBI::dbGetQuery(conn$handle, sql))
  }
  if (identical(conn$type, "mssql")) {
    stop("MSSQL SQL execution is not enabled in this skeleton.", call. = FALSE)
  }
  stop("SQL execution is not supported for connector type: ", conn$type, call. = FALSE)
}

#' Collect rows from an Arrow dataset connector
#'
#' @param conn A zashboard Arrow connection from \code{zashboard_connect_arrow()}.
#' @return A data frame with all rows.
#' @export
zashboard_execute_collect <- function(conn) {
  stopifnot(inherits(conn, "zashboard_conn"))
  if (!identical(conn$type, "arrow")) stop("This function only works with Arrow connectors.", call. = FALSE)
  if (!requireNamespace("arrow", quietly = TRUE)) stop("Package 'arrow' is required.", call. = FALSE)
  
  # Single Parquet file -> read directly (fast, no dplyr needed)
  if (isTRUE(conn$is_file)) {
    return(as.data.frame(arrow::read_parquet(conn$path)))
  }
  
  # Dataset directory -> try to_table()/ToTable(), else fall back to dplyr::collect()
  ds <- conn$handle
  
  # Some Arrow versions expose to_table(); others ToTable()
  to_table_fun <- NULL
  if (!is.null(ds$to_table) && is.function(ds$to_table)) to_table_fun <- ds$to_table
  if (is.null(to_table_fun) && !is.null(ds$ToTable) && is.function(ds$ToTable)) to_table_fun <- ds$ToTable
  
  if (!is.null(to_table_fun)) {
    tbl <- to_table_fun()
    return(as.data.frame(tbl))
  }
  
  if (requireNamespace("dplyr", quietly = TRUE)) {
    return(as.data.frame(dplyr::collect(ds)))
  }
  
  stop("Collecting from Arrow datasets requires either a recent 'arrow' with $to_table()/ToTable(), or 'dplyr' installed.", call. = FALSE)
}

#' Disconnect a zashboard connector
#'
#' Calls the embedded \code{disconnect} function if present.
#'
#' @param conn A zashboard connection object.
#' @return Invisibly \code{TRUE}.
#' @export
zashboard_disconnect <- function(conn) {
  stopifnot(inherits(conn, "zashboard_conn"))
  if (is.function(conn$disconnect)) conn$disconnect()
  invisible(TRUE)
}
