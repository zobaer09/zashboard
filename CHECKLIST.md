# Zashboard v1 Checklist

## Core spec and API
- [ ] Define spec schema and validator
- [ ] Implement build functions: static, shiny, shinylive, quarto
- [ ] Spec creation helpers
- [ ] Unit tests

## Data adapters
- [ ] DBI/odbc: SQL Server, Postgres
- [ ] dbplyr pushdown patterns
- [ ] Arrow dataset I/O
- [ ] DuckDB file query path

## Client engine & caching
- [ ] Include DuckDB WASM or Arrow JS
- [ ] manifest.json fetch + ETag logic
- [ ] Service Worker cache (app shell)
- [ ] IndexedDB cache (data partitions)

## Security & privacy
- [ ] No credentials in client
- [ ] Windows Integrated Auth example
- [ ] Privacy report generator

## Visuals
- [ ] KPI, bar, line, area, scatter, table, map
- [ ] Cross filtering in Shiny
- [ ] Linked filters in static

## Layout & theme
- [ ] Grid layout and matrix shorthand
- [ ] Breakpoints
- [ ] Shared theme tokens

## Performance
- [ ] Pagination and chunked reads
- [ ] Optional precompute
- [ ] Benchmarks

## CI & release
- [ ] CI for R CMD check
- [ ] Scheduled static render
- [ ] NEWS and versioning

## Docs & examples
- [ ] SQL Server example
- [ ] Parquet-only example
- [ ] Getting started
- [ ] Troubleshooting

## Accessibility & QA
- [ ] Keyboard navigation
- [ ] ARIA roles
- [ ] Contrast checks
