module AsciidoctorDiagramLayout
  module Renderer

    # Renders a layout node tree to SVG.
    #
    # Each cell produces a +<rect>+ with a linear gradient fill and centered
    # bold text.
    #
    class SvgRenderer
      DEFAULT_WIDTH  = 600 # :nodoc:
      DEFAULT_HEIGHT = 300 # :nodoc:
      FONT_SIZE      = 14  # :nodoc:

      # @param root    [ContainerNode] parsed layout tree
      # @param options [RenderOptions]
      # @return [String] SVG document
      def render(root, options = RenderOptions.new)
        w = parse_px(options.width,  DEFAULT_WIDTH)
        h = parse_px(options.height, DEFAULT_HEIGHT)
        defs = +""
        body = +""
        render_node(root, defs, body, options.color_scheme, 0, 0, w, h)
        sb = +""
        sb << "<svg xmlns=\"http://www.w3.org/2000/svg\""
        sb << " width=\"#{w}\""
        sb << " height=\"#{h}\""
        sb << " style=\"font-family:sans-serif;\""
        sb << ">\n"
        if options.title && !options.title.empty?
          sb << "  <title>#{escape_xml(options.title)}</title>\n"
        end
        if defs.length > 0
          sb << "  <defs>\n" << defs << "  </defs>\n"
        end
        sb << body
        sb << "</svg>\n"
        sb
      end

      private

      def parse_px(value, default_value)
        return default_value if value.nil?
        trimmed = value.end_with?("px") ? value[0..-3] : value
        Integer(trimmed.strip)
      rescue ArgumentError
        default_value
      end

      def render_node(node, defs, body, scheme, x, y, w, h)
        case node
        when ContainerNode then render_container(node, defs, body, scheme, x, y, w, h)
        when CellNode      then render_cell(node, defs, body, scheme, x, y, w, h)
        end
      end

      def render_container(container, defs, body, scheme, x, y, w, h)
        children = container.children
        total    = container.direction == :cols ? w : h
        sizes    = distribute_pixels(children, total)
        offset   = 0
        children.each_with_index do |child, i|
          cx = container.direction == :cols ? x + offset : x
          cy = container.direction == :cols ? y : y + offset
          cw = container.direction == :cols ? sizes[i] : w
          ch = container.direction == :cols ? h : sizes[i]
          render_node(child, defs, body, scheme, cx, cy, cw, ch)
          offset += sizes[i]
        end
      end

      def render_cell(cell, defs, body, scheme, x, y, w, h)
        label  = extract_label(cell.name)
        color  = scheme.fill_color(cell.name)
        light  = scheme.gradient_end(cell.name)
        stroke = scheme.stroke_color(cell.name)
        grad_id = "g#{x}-#{y}"
        defs << "    <linearGradient id=\"#{grad_id}\""
        defs << " gradientUnits=\"userSpaceOnUse\""
        defs << " x1=\"#{x}\" y1=\"#{y}\""
        defs << " x2=\"#{x + w}\" y2=\"#{y + h}\">\n"
        defs << "      <stop offset=\"0%\" stop-color=\"#{color}\"/>\n"
        defs << "      <stop offset=\"100%\" stop-color=\"#{light}\"/>\n"
        defs << "    </linearGradient>\n"
        body << "  <rect"
        body << " x=\"#{x}\""
        body << " y=\"#{y}\""
        body << " width=\"#{w}\""
        body << " height=\"#{h}\""
        body << " fill=\"url(##{grad_id})\""
        body << " stroke=\"#{stroke}\""
        body << " stroke-width=\"1\""
        body << "/>\n"
        tx = x + w / 2
        ty = y + h / 2
        body << "  <text"
        body << " x=\"#{tx}\""
        body << " y=\"#{ty}\""
        body << " text-anchor=\"middle\""
        body << " dominant-baseline=\"middle\""
        body << " font-size=\"#{FONT_SIZE}\""
        body << " font-weight=\"bold\""
        body << " fill=\"#333\""
        body << ">#{escape_xml(label)}</text>\n"
      end

      def distribute_pixels(children, total_pixels)
        fixed_sum  = 0
        auto_count = 0
        children.each do |child|
          s = child.size
          s == :auto ? auto_count += 1 : fixed_sum += s
        end
        remaining_percent = [0, 100 - fixed_sum].max
        auto_percent      = auto_count > 0 ? remaining_percent / auto_count : 0
        pixels = children.map do |child|
          pct = child.size == :auto ? auto_percent : child.size
          total_pixels * pct / 100
        end
        used      = pixels.sum
        remainder = total_pixels - used
        if remainder != 0
          (children.size - 1).downto(0) do |i|
            if children[i].size == :auto
              pixels[i] += remainder
              break
            end
          end
        end
        pixels
      end

      def extract_label(name)
        return "" if name.nil?
        name.gsub(/xref:[^\[]*\[([^\]]*)\]/, '\1')
            .gsub(/\{[^}]*\}/, "")
            .strip
      end

      def escape_xml(text)
        return "" if text.nil?
        text.gsub("&", "&amp;")
            .gsub("<", "&lt;")
            .gsub(">", "&gt;")
            .gsub('"', "&quot;")
      end
    end
  end
end
