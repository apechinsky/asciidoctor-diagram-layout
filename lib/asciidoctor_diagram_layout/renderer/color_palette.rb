module AsciidoctorDiagramLayout

  # Renderer subsystem (HTML and SVG backends).
  #
  module Renderer
    # Utility module for HSL-to-hex conversion and Java-compatible hashing.
    #
    # @api private
    module ColorPalette
      STROKE_COLOR = "#d0d0d0"      # :nodoc:
      GOLDEN_RATIO = 0.618033988749895 # :nodoc:
      HUE_RANGE    = 360            # :nodoc:

      # Converts HSL values to a hex color string.
      #
      # @param hue        [Integer] hue angle (0..359)
      # @param saturation [Integer] saturation (0..100)
      # @param lightness  [Integer] lightness  (0..100)
      # @return [String] hex color (e.g. "#d4d4d4")
      def self.hsl_to_hex(hue, saturation, lightness)
        s = saturation / 100.0
        l = lightness  / 100.0
        c = (1 - (2 * l - 1).abs) * s
        x = c * (1 - ((hue / 60.0) % 2 - 1).abs)
        m = l - c / 2.0
        if hue < 60
          r, g, b = c, x, 0
        elsif hue < 120
          r, g, b = x, c, 0
        elsif hue < 180
          r, g, b = 0, c, x
        elsif hue < 240
          r, g, b = 0, x, c
        elsif hue < 300
          r, g, b = x, 0, c
        else
          r, g, b = c, 0, x
        end
        ri = (r + m) * 255
        gi = (g + m) * 255
        bi = (b + m) * 255
        format("#%02x%02x%02x", ri.round, gi.round, bi.round)
      end

      # Java-compatible String#hashCode.
      #
      # Uses 32-bit signed overflow semantics, identical to the algorithm
      # defined in the Java Language Specification:
      #   s[0]*31^(n-1) + s[1]*31^(n-2) + ... + s[n-1]
      #
      # @param str [String]
      # @return [Integer] signed 32-bit hash code
      def self.java_hash(str)
        return 0 if str.nil? || str.empty?
        h = 0
        str.each_char do |c|
          h = (31 * h + c.ord) & 0xffffffff
        end
        h >= 0x80000000 ? h - 0x100000000 : h
      end
    end
  end
end
