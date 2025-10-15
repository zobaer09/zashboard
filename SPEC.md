# Zashboard V1 Spec (Working Copy)
**Source of truth:** _Zashboard V1 Living Spec And Checklist.pdf_
**This file:** a concise, working spec kept in sync with the PDF.

## Vision

Define one dashboard spec and build **four** targets from it:

1) **Static HTML** (safe interactivity for offline hosting)  
2) **Shiny app** (full interactivity, cross-filtering)  
3) **Shinylive app** (browser-executed Shiny via WebAssembly)  
4) **Quarto site** (literate site wrapper + docs around the dashboard; uses the same spec)

## Core Principles
- **One spec** drives all outputs (no forked authoring).
- **Data layer:** local analytics via **DuckDB** or **Arrow**; **Microsoft SQL Server** supported via **DBI/ODBC**.
- **Cross-filtering:** supported in Shiny; static builds use safe, non-executable interactivity.
- **Theming:** unified via **bslib** across targets.
- **Optional AI and MCP (Model Context Protocol):** **off by default**; only enabled explicitly.
- **Industrial-grade v1:** clarity, tests, CI, docs, reproducibility.

## Inputs & Repo Artifacts
- `CHECKLIST.md` — V1 scope checklist. ✅ (present)
- `inst/templates/zashboard.yml` — minimal spec template. ✅ (present)
- `scripts/build_static.R` — outline for static build pipeline. ✅ (present)
- `www/` — runtime assets (service worker, client loader, etc.). ✅ (present)
- `SPEC.md` — this file (working copy synced to the PDF). ✅ (now)

> If the ZIP contains additional schema files (e.g., manifest schema), we will add/align them here as they land.

## High-Level Requirements (V1)
- **Spec format:** YAML file (`zashboard.yml`) defining: 
  - data sources (DuckDB/Arrow, SQL Server via DBI/ODBC),
  - datasets (tables, joins/relationships),
  - measures/aggregations,
  - visuals (type, mappings, filters),
  - layout, theme tokens (bslib), and routes.
- **Build targets:**
  - **Static HTML:** pre-aggregated data artifacts, safe client interactions (no server).
  - **Shiny:** server-backed cross-filtering and drill behaviors.
  - **Shinylive:** Shiny in the browser, honoring the same spec.
  - **Quarto:** site wrapper + docs; renders to `_site/` locally and `docs/` on CI for Pages.
- **Theming:** a single theme map (bslib) applied consistently.
- **Caching & performance:** local DuckDB/Arrow caching; pushdown to SQL Server where appropriate.
- **Accessibility:** sensible aria labels, color-contrast defaults, keyboard navigability for core components.
- **Config toggles:** AI/MCP features opt-in only; never auto-enable or ship secrets.

## Non-Goals (V1)
- Full Power BI/DAX parity.
- Hosted service / multi-tenant sharing features.
- Complex row-level security (basic filters okay; full RLS deferred).

## Minimal Success Criteria
- A single `zashboard.yml` builds:
  - **/dist/static/** → static HTML output
  - **/dist/shiny/** → runnable Shiny app
  - **/dist/shinylive/** → runnable Shinylive app
- Basic visual set (bar/line/area, cards/kpis, table) with cross-filtering in Shiny.
- Theme applied consistently (bslib).
- Works offline for static site (service worker registered when enabled).

## Developer Experience
- **OS:** Windows 10/11; **R:** 4.3+; UTF-8, LF line endings.
- **Tooling:** renv (project libs), pak (fast install), devtools, roxygen2, testthat (3e), pkgdown.
- **CI:** GitHub Actions — R CMD check on Windows, macOS, Ubuntu.
- **License:** MIT.

## Open Items To Track
- [ ] Confirm presence (or add) **manifest schema** alongside `inst/templates/zashboard.yml`.
- [ ] Finalize spec keys and schema validation strategy.
- [ ] Document cross-filter semantics and supported visual interactions for V1.

## Pointers
- Author dashboard specs in: `inst/templates/zashboard.yml` (copy and modify per project)
- Build scripts entry point: `scripts/build_static.R` (static pipeline)
- Runtime assets: `www/` (service worker, client loader, etc.)
