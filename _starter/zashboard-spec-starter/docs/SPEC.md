# Zashboard, product plan v1

This is a condensed spec. The living spec in your ChatGPT canvas should be copied here as needed.

## Executive summary
Define once, build as static HTML, Shiny, or Shinylive. Light semantic layer. Cross filtering. Theming. Data from servers or files.
Optional AI/MCP, disabled by default. Optional client-side analytics (DuckDB WASM / Arrow JS) for static builds.

## Goals
- One spec for static and dynamic.
- Pushdown to servers, local caching, fast aggregates.
- Clear visuals and consistent theming.
- Offline-first with Service Worker and IndexedDB.
- Versioned datasets and a small manifest file.

## Non-goals v1
- Full Power BI service or DAX.
- Enterprise governance.
- Drag-and-drop designer (post v1).

## Uniqueness
- Single spec, multiple runtimes.
- Light semantic layer compiling to SQL or columnar compute.
- Cross filtering in Shiny, safe linking plus small client recompute in static.
- Unified theming.

## Engines
- Arrow for columnar files and lakes.
- DuckDB for local compute and WASM in browser.

## Data connectivity v1
- DBI/odbc for SQL Server, Postgres, MySQL, Snowflake, BigQuery.
- Files: Parquet, CSV, JSON (Arrow/DuckDB).
- dbplyr pushdown where possible.
- Pool for Shiny.

## Security
- No secrets in client code.
- Encrypted ODBC where drivers allow.
- Windows Integrated Authentication examples.
- Optional edge functions for private aggregates.

## Interactivity
- Dynamic (Shiny): full cross filtering.
- Static: linked filters and light client recompute, or precomputed tiles.
- Drill to detail both modes.
- Stale-while-revalidate for data refresh.

## Visuals v1
KPI, bar, line, area, scatter, histogram, heatmap, treemap, table, basic map. Optional Vega-Lite for static.

## Semantic v1
Relationships, measures (sum, count, distinct, avg, min, max, time-aware), time intelligence helpers.

## Build targets
`build_static`, `build_shiny`, `build_shinylive`, `build_quarto`.

## API surface (intent)
Spec creation helpers, connectors, validators, build functions, optional AI module toggles.

## Performance
Pushdown by default, local caches, precompute for static, pagination/chunked reads, async fetch in Shiny.

## Governance & deploy
Static hosting anywhere. Shiny hosts. CI templates for scheduled rebuilds and gh-pages deploy.

## Acceptance (v1)
Same spec builds static and Shiny with same layout/theme. Two server sources certified. Parquet/CSV supported.
Cross filtering in Shiny. Static has linked filters and simple aggregates. Example project. Accessibility basics pass.
