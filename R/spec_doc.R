#' Zashboard spec (v1) — minimal schema
#'
#' This documents the minimal keys that a v1 Zashboard spec must provide.
#'
#' Top-level fields:
#' - `title` *(optional)*: character. Used for page/app titles.
#' - `datasets` *(required)*: **named list** of data sources (e.g., table names, files).
#' - `filters` *(optional)*: list of filter definitions.
#' - `charts` *(required)*: list; each chart has at least `id` (string) and `type` (string).
#' - `layout` *(required)*: list describing placement or groupings.
#'
#' See [zashboard_read_spec()], [zashboard_validate_spec()], and [zashboard_manifest()].
#'
#' @section Minimal YAML example:
#' \preformatted{
#' title: "Zashboard"
#'
#' datasets:
#'   visits_by_borough:
#'     source: duckdb
#'     table:  visits_by_borough
#'
#' filters:
#'   borough:
#'     type: select
#'     dataset: visits_by_borough
#'     column: borough
#'
#' charts:
#'   - id: visits_by_borough
#'     type: bar
#'     dataset: visits_by_borough
#'     x: borough
#'     y: visits
#'
#' layout:
#'   rows:
#'     - [visits_by_borough]
#' }
#'
#' @name zashboard_spec
#' @keywords documentation
NULL
