# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this project is

`row_col_layout` is a Ruby gem providing an Asciidoctor block extension. It adds a `[layout]` block to AsciiDoc documents that renders flex-based layout diagrams as HTML or SVG. The layout is described in a simple line-oriented DSL.

## Commands

Run all tests:
```
bundle exec rspec
```

Run a single spec file:
```
bundle exec rspec spec/parser_spec.rb
```

Install dependencies:
```
bundle install
```

There is no build step; the gem is loaded directly from source via `require`.

## Architecture

The pipeline is: **DSL text -> Parser -> node tree -> Renderer -> HTML or SVG string**.

### DSL and Parser (`lib/row_col_layout/parser.rb`)

`Parser#parse` takes DSL text and returns a tree of two node types:

- `ContainerNode(direction, size, children)` - a `rows:` or `cols:` block
- `CellNode(size, name)` - a leaf `cell:` entry

Indentation (4 spaces or 1 tab) determines nesting. An optional `(N)` suffix sets a fixed percentage size; omitting it gives `:auto`. Multiple top-level nodes are wrapped in an implicit `ContainerNode` whose direction defaults to `:rows` (overridable via the `direction` block attribute).

### Renderers (`lib/row_col_layout/renderer/`)

Two renderers share the same node tree interface:

- `HtmlRenderer` - emits inline `<div>` elements with flexbox CSS. Sizes map to `flex:1` (auto) or `flex:0 0 N%` (fixed).
- `SvgRenderer` - computes pixel geometry recursively, emits `<rect>` and `<text>` elements with `<linearGradient>` defs. Width/height must be parseable as integers (with optional `px` suffix); defaults are 600x300.

`RenderOptions` bundles width, height, palette name, pdf flag, and an optional `name_converter` proc.

### Color schemes (`lib/row_col_layout/renderer/scheme/`)

`CellColorSchemeFactory.resolve(name, pdf:)` returns a scheme object that responds to `fill_color(name)`, `gradient_end(name)`, and `stroke_color(name)`. Available palettes: `rainbow` (default), `pastel`, `warm`, `cool`, `mono`. Colors are derived deterministically from the cell name via a Java-compatible `String.hashCode` in `ColorPalette`, so the same name always produces the same color.

### Asciidoctor integration (`lib/row_col_layout/asciidoc/layout_block_processor.rb`)

`LayoutBlockProcessor` registers as a `BlockProcessor` for the `:layout` name on `:listing`/`:literal` contexts. It reads block attributes (`renderer`, `direction`, `palette`, `width`, `height`, `target`) and selects HTML or SVG rendering. For PDF backend the SVG is written to a file (using `target` attribute as the filename) and referenced via `create_image_block`. For HTML backends the output is injected as a pass-through block.

## DSL syntax reference

```
cols:
  cell(30): Sidebar    # fixed 30%
  rows:                # nested container
    cell: Header       # auto size
    cell: Content      # auto size
# comments are stripped
```

Keywords are case-insensitive. Container nodes (`cols:`, `rows:`) must not have a value on the same line. `cell:` must have a non-empty name. `xref:anchor[Label]` macros and `{attribute}` references in cell names are stripped in SVG output.
