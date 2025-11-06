# zashboard 0.1.0 (2025-10-15)

- First public release candidate.
- One spec builds **four** targets: Static HTML, Shiny, Shinylive, and Quarto.
- New helpers: `build_all()` for one-shot builds; `zashboard_init()` scaffolds a spec folder.
- Connectors: DuckDB, Arrow, and Microsoft SQL Server (via DBI/ODBC).
- Theming: `zashboard_theme()` applies a consistent bslib theme.
- Docs: pkgdown site, getting-started vignette, and spec help (`?zashboard_spec`).
- CI: R CMD check matrix + pkgdown deploy.
- Dev UX: local preview scripts and pre-push checker.

# zashboard 0.0.0.9000

- Development version.
