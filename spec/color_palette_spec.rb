require_relative "../lib/asciidoctor-diagram-layout"

RSpec.describe AsciidoctorDiagramLayout::Renderer::ColorPalette do
  describe ".java_hash" do
    # these values are verified against Java String.hashCode()
    it { expect(described_class.java_hash("Header")).to eq(-2137403731) }
    it { expect(described_class.java_hash("Content")).to eq(-1678783399) }
    it { expect(described_class.java_hash("")).to eq(0) }
    it { expect(described_class.java_hash(nil)).to eq(0) }
  end

  describe ".hsl_to_hex" do
    it { expect(described_class.hsl_to_hex(0,   100, 50)).to eq("#ff0000") }
    it { expect(described_class.hsl_to_hex(120, 100, 50)).to eq("#00ff00") }
    it { expect(described_class.hsl_to_hex(240, 100, 50)).to eq("#0000ff") }
    it { expect(described_class.hsl_to_hex(0,   0,   100)).to eq("#ffffff") }
    it { expect(described_class.hsl_to_hex(0,   0,   0)).to eq("#000000") }
  end
end
