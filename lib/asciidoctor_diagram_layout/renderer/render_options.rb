module AsciidoctorDiagramLayout
  module Renderer

    # Configuration for a single render pass.
    #
    # @example Custom palette and dimensions
    #   RenderOptions.new(width: "800px", height: "400px", palette: "pastel", title: "My Layout")
    #
    class RenderOptions
      attr_reader :width, :height, :title, :color_scheme, :name_converter

      # @param width          [String] CSS width (e.g. "100%", "600px")
      # @param height         [String, nil] CSS height or +nil+
      # @param title          [String, nil] diagram caption
      # @param palette        [String] palette name passed to {Scheme::CellColorSchemeFactory.resolve}
      # @param pdf            [Boolean] whether the output backend is PDF
      # @param color_scheme   [Scheme::ColorScheme, nil] pre-resolved scheme, skips factory
      # @param name_converter [Proc, nil] Callable receiving a cell name and returning a rendered
      #   label.  Defaults to XML-escaping.
      #
      def initialize(width: "100%", height: nil, title: nil, palette: "rainbow", pdf: false,
                     color_scheme: nil, name_converter: nil)
        @width          = width
        @height         = height
        @title          = title
        @color_scheme   = color_scheme || Scheme::CellColorSchemeFactory.resolve(palette, pdf: pdf)
        @name_converter = name_converter || ->(text) { escape(text) }
      end

      private

      def escape(text)
        return "" if text.nil?
        text.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
      end
    end
  end
end
