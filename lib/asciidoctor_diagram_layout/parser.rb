module AsciidoctorDiagramLayout

  # Raised when the DSL input is malformed.
  class ParseError < StandardError; end

  # Parses rowcol layout DSL text into a node tree.
  #
  # Format: one directive per line.  Containers (cols, rows) declare
  # a nested block via indentation.  Leaf zones use +cell+.
  #
  # An optional size in parentheses sets a fixed percentage:
  #   cell(30): Name
  #   cols(40):
  #
  # @example Two-column layout
  #   Parser.new.parse("cols:\n  cell: Sidebar\n  cell: Content\n")
  #
  class Parser
    LINE_PATTERN = /\A(?<keyword>cols|rows|cell)(?:\((?<size>\d+)\))?:(?<rest>.*)\z/i # :nodoc:
    TAB_WIDTH    = 4 # :nodoc:

    # Parses a DSL string and returns a {ContainerNode} tree root.
    #
    # @param dsl               [String] layout DSL
    # @param implicit_direction [Symbol] +:rows+ or +:cols+ — fallback
    #   direction when the top-level is a bare cell
    # @return [ContainerNode]
    # @raise  [ParseError] on syntax errors or empty input
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

  # Internal parser position tracker.
  #
  # @!visibility private
  ParseState = Struct.new(:lines, :index) do
    # :nodoc:
    def initialize(lines)
      super(lines, 0)
    end

    def more?
      index < lines.size
    end

    # @!visibility private
    def peek
      lines[index]
    end

    # @!visibility private
    def advance
      self.index += 1
    end
  end

  # A container node holding child nodes in a row or column direction.
  #
  # @!attribute direction
  #   @return [:cols, :rows] flex direction
  # @!attribute size
  #   @return [Integer, :auto] percentage of parent or +:auto+ for flex grow
  # @!attribute children
  #   @return [Array<ContainerNode, CellNode>]
  ContainerNode = Struct.new(:direction, :size, :children)

  # A leaf node representing a named cell.
  #
  # @!attribute size
  #   @return [Integer, :auto] percentage of parent or +:auto+ for flex grow
  # @!attribute name
  #   @return [String] cell name, may contain AsciiDoc inline macros
  CellNode = Struct.new(:size, :name)
end
