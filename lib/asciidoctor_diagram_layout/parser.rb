module AsciidoctorDiagramLayout
  class ParseError < StandardError; end

  # Parses flex layout DSL text into a node tree.
  #
  # Format: one directive per line. Containers (cols, rows) declare
  # a nested block via indentation. Leaf zones use cell.
  # An optional size in parentheses sets a fixed percentage:
  #   cell(30): Name  or  cols(40):
  class Parser
    LINE_PATTERN = /\A(?<keyword>cols|rows|cell)(?:\((?<size>\d+)\))?:(?<rest>.*)\z/i
    TAB_WIDTH    = 4

    def parse(dsl, implicit_direction = :rows)
      lines = dsl.split("\n", -1)
      state = ParseState.new(lines)
      roots = parse_children(state, 0)
      raise ParseError, "Empty input: expected at least one cell, rows, or cols" if roots.empty?
      if roots.size == 1 && roots.first.is_a?(ContainerNode)
        roots.first
      else
        ContainerNode.new(implicit_direction, :auto, roots)
      end
    end

    private

    def parse_children(state, indent)
      nodes = []
      while state.more?
        line   = state.peek
        trimmed = strip_comment(line).rstrip
        if trimmed.strip.empty?
          state.advance
          next
        end
        line_indent = count_indent(line)
        break if line_indent < indent
        if line_indent > indent
          raise ParseError, "Unexpected indentation at line #{state.index + 1}: #{line.inspect}"
        end
        state.advance
        content = trimmed.strip
        m = LINE_PATTERN.match(content)
        raise ParseError, "Invalid syntax at line #{state.index}: #{line.inspect}" unless m
        keyword   = m[:keyword].downcase
        size      = m[:size] ? m[:size].to_i : :auto
        rest      = m[:rest].strip
        nodes << build_node(keyword, size, rest, state, indent, state.index, line)
      end
      nodes
    end

    def build_node(keyword, size, rest, state, indent, line_number, original_line)
      if keyword == "cell"
        raise ParseError, "cell requires a name at line #{line_number}: #{original_line.inspect}" if rest.empty?
        return CellNode.new(size, rest)
      end
      unless rest.empty?
        raise ParseError, "#{keyword} is a container and must not have a value at line #{line_number}: #{original_line.inspect}"
      end
      direction     = keyword == "cols" ? :cols : :rows
      nested_indent = detect_nested_indent(state, indent, line_number)
      children      = parse_children(state, nested_indent)
      ContainerNode.new(direction, size, children)
    end

    def detect_nested_indent(state, current_indent, line_number)
      while state.more?
        line    = state.peek
        trimmed = strip_comment(line).rstrip
        unless trimmed.strip.empty?
          indent = count_indent(line)
          if indent <= current_indent
            raise ParseError, "Expected indented block after line #{line_number} but found: #{line.inspect}"
          end
          return indent
        end
        state.advance
      end
      raise ParseError, "Expected indented block after line #{line_number} but reached end of input"
    end

    def count_indent(line)
      count = 0
      line.each_char do |c|
        if c == ' '
          count += 1
        elsif c == "\t"
          count += TAB_WIDTH
        else
          break
        end
      end
      count
    end

    def strip_comment(line)
      i = line.index('#')
      i ? line[0, i] : line
    end
  end

  ParseState = Struct.new(:lines, :index) do
    def initialize(lines)
      super(lines, 0)
    end

    def more?
      index < lines.size
    end

    def peek
      lines[index]
    end

    def advance
      self.index += 1
    end
  end

  ContainerNode = Struct.new(:direction, :size, :children)
  CellNode      = Struct.new(:size, :name)
end
