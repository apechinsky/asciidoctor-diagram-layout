require_relative "../lib/asciidoctor-diagram-layout"

RSpec.describe AsciidoctorDiagramLayout::Renderer::SvgRenderer do
  let(:parser)   { AsciidoctorDiagramLayout::Parser.new }
  let(:renderer) { described_class.new }

  it "produces valid svg root element" do
    root = parser.parse("cols:\n  cell: A\n  cell: B\n")
    svg  = renderer.render(root)
    expect(svg).to start_with("<svg ")
    expect(svg).to end_with("</svg>\n")
  end

  it "renders cell names as text elements" do
    root = parser.parse("rows:\n  cell: Header\n  cell: Footer\n")
    svg  = renderer.render(root)
    expect(svg).to include(">Header<")
    expect(svg).to include(">Footer<")
  end

  it "renders gradient defs" do
    root = parser.parse("cols:\n  cell: Content\n")
    svg  = renderer.render(root)
    expect(svg).to include("<defs>")
    expect(svg).to include("linearGradient")
  end

  it "uses gradientUnits=userSpaceOnUse" do
    root = parser.parse("cols:\n  cell: Content\n")
    expect(renderer.render(root)).to include('gradientUnits="userSpaceOnUse"')
  end

  it "strips xref macros from cell names" do
    root = parser.parse("cols:\n  cell: xref:anchor[Display Text]\n")
    svg  = renderer.render(root)
    expect(svg).to include(">Display Text<")
    expect(svg).not_to include("xref:")
  end

  it "escapes xml in cell names" do
    root = parser.parse("cols:\n  cell: A & B\n")
    expect(renderer.render(root)).to include("A &amp; B")
  end

  it "respects custom width and height in px" do
    root    = parser.parse("cols:\n  cell: Content\n")
    options = AsciidoctorDiagramLayout::Renderer::RenderOptions.new(width: "800px", height: "400px")
    svg     = renderer.render(root, options)
    expect(svg).to include('width="800"')
    expect(svg).to include('height="400"')
  end

  it "renders title element when title is set" do
    root    = parser.parse("cols:\n  cell: Content\n")
    options = AsciidoctorDiagramLayout::Renderer::RenderOptions.new(title: "My Diagram")
    svg     = renderer.render(root, options)
    expect(svg).to include("<title>My Diagram</title>")
  end

  it "does not render title element when title is absent" do
    root = parser.parse("cols:\n  cell: Content\n")
    expect(renderer.render(root)).not_to include("<title>")
  end

  it "escapes xml in title" do
    root    = parser.parse("cols:\n  cell: Content\n")
    options = AsciidoctorDiagramLayout::Renderer::RenderOptions.new(title: "A & B <diagram>")
    svg     = renderer.render(root, options)
    expect(svg).to include("<title>A &amp; B &lt;diagram&gt;</title>")
  end
end
