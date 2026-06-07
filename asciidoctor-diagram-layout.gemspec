require_relative "lib/asciidoctor_diagram_layout/version"

Gem::Specification.new do |s|
  s.name        = "asciidoctor-diagram-layout"
  s.version     = AsciidoctorDiagramLayout::VERSION
  s.summary     = "Asciidoctor extension for rendering flex layout diagrams"
  s.description = "Provides a [layout] block for Asciidoctor that renders layout diagrams as HTML or SVG."
  s.authors     = ["Anton Pechinsky"]
  s.email       = "anton@pechinsky.com"
  s.license     = "Apache-2.0"
  s.files       = Dir["lib/**/*.rb"] + ["LICENSE"]
  s.require_paths = ["lib"]
  s.add_dependency "asciidoctor", ">= 2.0"
  s.add_development_dependency "rspec", "~> 3.0"
end
