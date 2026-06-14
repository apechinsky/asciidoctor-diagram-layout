require "asciidoctor"
require "asciidoctor/extensions"

module AsciidoctorDiagramLayout

  # Asciidoctor integration — block processor and extension registration.
  #
  module Asciidoc
    # Asciidoctor block processor for the +[layout]+ block.
    #
    # Parses a DSL body into a layout tree and renders it as inline HTML
    # (HTML backend) or standalone SVG (all other backends).
    class LayoutBlockProcessor < Asciidoctor::Extensions::BlockProcessor
      use_dsl
      named :"layout-rowcol"
      on_contexts :listing, :literal
      name_positional_attributes "target"

      # @param parent [Asciidoctor::Block] parent block
      # @param reader [Asciidoctor::Reader] DSL source reader
      # @param attrs  [Hash] block attributes
      # @return [Asciidoctor::Block] rendered block
      def process(parent, reader, attrs)
        dsl           = reader.read
        implicit_dir  = attrs["direction"] == "cols" ? :cols : :rows
        root          = Parser.new.parse(dsl, implicit_dir)
        backend       = parent.document.attr("backend").to_s
        strategy      = resolve_strategy(attrs["renderer"], backend)
        palette       = attrs.fetch("palette", "rainbow")
        pdf           = backend == "pdf"
        title         = attrs["title"]
        options       = Renderer::RenderOptions.new(
          width:          attrs.fetch("width", "100%"),
          height:         attrs["height"],
          title:          title,
          palette:        palette,
          pdf:            pdf,
          name_converter: ->(name) { convert_inline(parent, name) }
        )
        case strategy
        when :html then render_html(parent, root, options)
        when :svg  then render_svg(parent, root, backend, options, attrs, title)
        end
      end

      private

      def resolve_strategy(renderer_attr, backend)
        case renderer_attr.to_s.downcase
        when "html" then :html
        when "svg"  then :svg
        else
          case backend.downcase
          when "html", "html5" then :html
          else :svg
          end
        end
      end

      def render_html(parent, root, options)
        html = Renderer::HtmlRenderer.new.render(root, options)
        create_pass_block(parent, html, {}, subs: nil)
      end

      def render_svg(parent, root, backend, options, attrs, title)
        svg    = Renderer::SvgRenderer.new.render(root, options)
        target = attrs["target"]
        outdir = parent.document.attr("outdir").to_s
        path   = write_svg(svg, target, outdir)
        filename = File.basename(path)
        parent.document.register(:images, filename)
        img_target = backend == "pdf" ? File.expand_path(path) : filename
        block = create_image_block(parent, { "target" => img_target, "format" => "svg" })
        block.title = title if title && !title.empty?
        block
      end

      def write_svg(svg, name, outdir)
        has_outdir = outdir && outdir != "null" && !outdir.empty?
        has_name   = name && !name.empty?
        if has_outdir && has_name
          path = File.join(outdir, "#{name}.svg")
        elsif has_name
          path = File.join(Dir.tmpdir, "#{name}-#{SecureRandom.hex(4)}.svg")
        else
          path = File.join(Dir.tmpdir, "layout-#{SecureRandom.hex(4)}.svg")
        end
        File.write(path, svg, encoding: "UTF-8")
        path
      end

      def convert_inline(node, text)
        escaped  = node.sub_specialchars(text)
        node.sub_macros(escaped)
      end
    end
  end
end
