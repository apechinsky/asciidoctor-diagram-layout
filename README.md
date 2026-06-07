# asciidoctor-diagram-layout

An Asciidoctor extension that adds a `[layout-rowcol]` block for rendering
UI layout diagrams.

## Installation

Add to your `Gemfile`:

```ruby
gem "asciidoctor-diagram-layout"
```

Or install directly:

```
gem install asciidoctor-diagram-layout
```

## Usage

### Basic example

```asciidoc
[layout-rowcol]
----
cell: Header
cols:
  cell(30): Sidebar
  cell: Content
cell: Header
----
```

### DSL syntax

Each line declares one node. Indentation (4 spaces or one tab) defines
nesting.

* `rows:` - container that arranges children vertically.
  May be omitted at the top level.
* `cols:` - container that arranges children horizontally
* `cell: Name` - leaf cell with a visible label
* `cell(30): Name` - leaf cell with a fixed size of 30% of its parent
* Containers without an explicit size take equal shares of the remaining
  space
* Lines starting with `#` are comments

### Block attributes

* `direction` - implicit direction for top-level cells when no container
  is declared: `rows` (default) or `cols`
* `renderer` - force output format: `html` or `svg`; defaults to `html`
  for HTML backends and `svg` for all others including PDF
* `width` - diagram width, e.g. `100%` (default) or `800px`
* `height` - diagram height, e.g. `400px`; not set by default
* `target` - SVG file name (without extension) when rendering to PDF
* `palette` - color scheme: `rainbow` (default), `pastel`, `warm`,
  `cool`, `mono`

### PDF output

When converting to PDF, the extension writes the diagram as an SVG file
and embeds it as an image block.
Use the `target` attribute to control the output file name:

```asciidoc
[layout-rowcol, target="my-diagram"]
----
cols:
    cell: Left
    cell: Right
----
```

## License

Apache License 2.0.
See [LICENSE](LICENSE).
