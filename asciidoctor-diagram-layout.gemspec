require_relative "lib/asciidoctor_diagram_layout/version"

Gem::Specification.new do |s|
  s.name        = "asciidoctor-diagram-layout"
  s.version     = AsciidoctorDiagramLayout::VERSION
  s.summary     = "Asciidoctor extension for rendering flex layout diagrams"
  s.description = "Provides a [layout] block for Asciidoctor that renders layout diagrams as HTML or SVG."
  s.authors     = ["Anton Pechinsky"]
  s.email       = "anton@pechinsky.com"
  s.homepage    = "https://github.com/apechinsky/asciidoctor-diagram-layout"
  s.license     = "Apache-2.0"
  s.files       = Dir["lib/**/*.rb"] + ["LICENSE", "README.md"]
  s.require_paths = ["lib"]
  s.required_ruby_version = ">= 2.7"
  s.add_dependency "asciidoctor", "~> 2.0"
  s.add_development_dependency "rspec", "~> 3.0"
  s.add_development_dependency "rake", "~> 13.0"
  s.add_development_dependency "erb"
end
