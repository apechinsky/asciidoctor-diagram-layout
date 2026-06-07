module AsciidoctorDiagramLayout
  module Renderer
    class RenderOptions
      attr_reader :width, :height, :color_scheme, :name_converter

      def initialize(width: "100%", height: nil, palette: "rainbow", pdf: false,
                     color_scheme: nil, name_converter: nil)
        @width          = width
        @height         = height
        @color_scheme   = color_scheme || Scheme::CellColorSchemeFactory.resolve(palette, pdf: pdf)
        @name_converter = name_converter || method(:escape)
      end

      private

      def escape(text)
        return "" if text.nil?
        text.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
      end
    end
  end
end
