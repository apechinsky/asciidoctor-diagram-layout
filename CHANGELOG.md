# Changelog

## [1.2.0] - 2026-06-14

### Added

- `bw` palette — black-and-white scheme (white fill, black stroke, no visible gradient)
- Asciidoctor.js implementation for VS Code preview support (`lib/asciidoctor_diagram_layout/js/layout-rowcol.js`)

### Changed

- Factory `CellColorSchemeFactory`: added explicit `"rainbow"` case; unknown palette name now raises `ArgumentError`
- Naming: "flex layout" replaced with "rowcol layout" in comments and gemspec

## [1.1.0] - 2026-06-09

### Added

- Block title (`.Title` syntax) is now rendered as a figure caption
- Cell names support inline AsciiDoc macros: `xref:`, `link:`, attribute references
- `target` attribute accepts the output filename as a positional attribute
  (second position) or as a named attribute

## [1.0.1] - 2024-01-01

Initial public release.
