require_relative "../lib/asciidoctor-diagram-layout"

RSpec.describe AsciidoctorDiagramLayout::Renderer::HtmlRenderer do
  let(:parser)   { AsciidoctorDiagramLayout::Parser.new }
  let(:renderer) { described_class.new }

  it "renders cols container with flex-direction:row" do
    root = parser.parse("cols:\n  cell: A\n  cell: B\n")
    expect(renderer.render(root)).to include("flex-direction:row")
  end

  it "renders rows container with flex-direction:column" do
    root = parser.parse("rows:\n  cell: A\n  cell: B\n")
    expect(renderer.render(root)).to include("flex-direction:column")
  end

  it "renders auto-size cell with flex:1" do
    root = parser.parse("cols:\n  cell: Content\n")
    expect(renderer.render(root)).to include("flex:1")
  end

  it "renders fixed-size cell with flex:0 0 30%" do
    root = parser.parse("cols:\n  cell(30): Sidebar\n  cell: Content\n")
    expect(renderer.render(root)).to include("flex:0 0 30%")
  end

  it "renders cell names" do
    root = parser.parse("rows:\n  cell: Header\n  cell: Footer\n")
    html = renderer.render(root)
    expect(html).to include(">Header<")
    expect(html).to include(">Footer<")
  end

  it "renders gradient background" do
    root = parser.parse("cols:\n  cell: Content\n")
    expect(renderer.render(root)).to include("linear-gradient")
  end

  it "escapes html in cell names" do
    root = parser.parse("cols:\n  cell: <script>alert(1)</script>\n")
    html = renderer.render(root)
    expect(html).not_to include("<script>")
    expect(html).to include("&lt;script&gt;")
  end

  it "respects custom width" do
    root    = parser.parse("cols:\n  cell: Content\n")
    options = AsciidoctorDiagramLayout::Renderer::RenderOptions.new(width: "800px")
    expect(renderer.render(root, options)).to include("width:800px")
  end

  it "wraps output in imageblock div when title is set" do
    root    = parser.parse("cols:\n  cell: Content\n")
    options = AsciidoctorDiagramLayout::Renderer::RenderOptions.new(title: "My Layout")
    html    = renderer.render(root, options)
    expect(html).to include('<div class="imageblock">')
    expect(html).to include('<div class="title">My Layout</div>')
    expect(html).to include('<div class="content">')
  end

  it "does not wrap output when title is absent" do
    root = parser.parse("cols:\n  cell: Content\n")
    html = renderer.render(root)
    expect(html).not_to include('<div class="imageblock">')
  end
end
