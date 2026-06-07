module AsciidoctorDiagramLayout
  module Renderer
    class HtmlRenderer
      CELL_BASE = "display:flex; align-items:center; justify-content:center;" \
                  " padding:8px; font-weight:bold; font-family:sans-serif;" \
                  " min-height:60px; box-sizing:border-box; color:#333;"

      def render(root, options = RenderOptions.new)
        sb = +""
        height_style = options.height ? " min-height:#{options.height};" : ""
        wrapper_style = "display:flex; width:#{options.width};#{height_style}" \
                        " box-sizing:border-box; font-family:sans-serif; overflow:hidden;"
        sb << "<div style=\"#{wrapper_style}\">\n"
        render_node(root, sb, 1, options)
        sb << "</div>\n"
        sb
      end

      private

      def render_node(node, sb, depth, options)
        case node
        when ContainerNode then render_container(node, sb, depth, options)
        when CellNode      then render_cell(node, sb, depth, options)
        end
      end

      def render_container(container, sb, depth, options)
        flex_dir = container.direction == :cols ? "row" : "column"
        style = "display:flex; flex-direction:#{flex_dir}; #{size_style(container.size)}" \
                " align-items:stretch; box-sizing:border-box;"
        indent(sb, depth)
        sb << "<div style=\"#{style}\">\n"
        container.children.each { |child| render_node(child, sb, depth + 1, options) }
        indent(sb, depth)
        sb << "</div>\n"
      end

      def render_cell(cell, sb, depth, options)
        scheme   = options.color_scheme
        color    = scheme.fill_color(cell.name)
        grad_end = scheme.gradient_end(cell.name)
        stroke   = scheme.stroke_color(cell.name)
        gradient = "linear-gradient(135deg,#{color},#{grad_end})"
        style    = "#{CELL_BASE} #{size_style(cell.size)}" \
                   " background:#{gradient}; border:1px solid #{stroke};"
        indent(sb, depth)
        sb << "<div style=\"#{style}\">#{options.name_converter.call(cell.name)}</div>\n"
      end

      def size_style(size)
        size == :auto ? "flex:1;" : "flex:0 0 #{size}%; box-sizing:border-box;"
      end

      def indent(sb, depth)
        sb << "  " * depth
      end
    end
  end
end
