require_relative "../lib/asciidoctor-diagram-layout"

RSpec.describe AsciidoctorDiagramLayout::Parser do
  subject(:parser) { described_class.new }

  it "parses implicit rows with cells" do
    root = parser.parse("cell: A\ncell: B\n")
    expect(root).to be_a(AsciidoctorDiagramLayout::ContainerNode)
    expect(root.direction).to eq(:rows)
    expect(root.children.size).to eq(2)
  end

  it "parses explicit cols container" do
    root = parser.parse("cols:\n  cell: A\n  cell: B\n")
    expect(root.direction).to eq(:cols)
  end

  it "parses fixed size cell" do
    root = parser.parse("cols:\n  cell(30): Sidebar\n  cell: Content\n")
    expect(root.children.first.size).to eq(30)
    expect(root.children.last.size).to eq(:auto)
  end

  it "strips comments" do
    root = parser.parse("cols: # comment\n  cell: A\n  cell: B\n")
    expect(root.children.size).to eq(2)
  end

  it "raises on empty input" do
    expect { parser.parse("") }.to raise_error(AsciidoctorDiagramLayout::ParseError)
  end

  it "parses nested containers" do
    dsl = "cols:\n  cell(30): Sidebar\n  rows:\n    cell: Header\n    cell: Content\n"
    root = parser.parse(dsl)
    expect(root.children.size).to eq(2)
    expect(root.children.last).to be_a(AsciidoctorDiagramLayout::ContainerNode)
  end
end
