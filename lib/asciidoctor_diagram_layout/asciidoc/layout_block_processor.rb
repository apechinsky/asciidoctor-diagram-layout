require "asciidoctor"
require "asciidoctor/extensions"

module AsciidoctorDiagramLayout
  module Asciidoc
    class LayoutBlockProcessor < Asciidoctor::Extensions::BlockProcessor
      use_dsl
      named :layout
      on_contexts :listing, :literal

      def process(parent, reader, attrs)
        dsl               = reader.read
        implicit_dir      = attrs["direction"] == "cols" ? :cols : :rows
        root              = Parser.new.parse(dsl, implicit_dir)
        backend           = parent.document.attr("backend").to_s
        renderer_attr     = attrs["renderer"]
        strategy          = resolve_strategy(renderer_attr, backend)
        palette           = attrs.fetch("palette", "rainbow")
        pdf               = backend == "pdf"
        options           = Renderer::RenderOptions.new(
          width:          attrs.fetch("width", "100%"),
          height:         attrs["height"],
          palette:        palette,
          pdf:            pdf,
          name_converter: method(:identity)
        )
        case strategy
        when :html then render_html(parent, root, options)
        when :svg  then render_svg(parent, root, backend, options, attrs)
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

      def render_svg(parent, root, backend, options, attrs)
        svg = Renderer::SvgRenderer.new.render(root, options)
        if backend == "pdf"
          target = attrs["target"]
          outdir = parent.document.attr("outdir").to_s
          path   = write_svg(svg, target, outdir)
          create_image_block(parent, { "target" => path, "format" => "svg" })
        else
          create_pass_block(parent, svg, {}, subs: nil)
        end
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

      def identity(text)
        text
      end
    end
  end
end
