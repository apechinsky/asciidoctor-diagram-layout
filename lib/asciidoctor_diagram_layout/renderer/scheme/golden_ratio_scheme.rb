module AsciidoctorDiagramLayout
  module Renderer
    module Scheme

      # Spreads hues across the full 360-degree range using the golden ratio.
      #
      # Each cell name's Java hash determines its position on the hue circle,
      # ensuring visually distinct colors for adjacent names.
      #
      class GoldenRatioScheme
        include ColorScheme

        GRADIENT_HUE_SHIFT = 20 # :nodoc:
        STROKE_LIGHTNESS   = 65 # :nodoc:
        STROKE_SATURATION  = 30 # :nodoc:

        # @param saturation [Integer] HSL saturation (0..100)
        # @param lightness  [Integer] HSL lightness  (0..100)
        def initialize(saturation, lightness)
          @saturation = saturation
          @lightness  = lightness
        end

        # :nodoc:
        def fill_color(name)
          ColorPalette.hsl_to_hex(hue(name), @saturation, @lightness)
        end

        # :nodoc:
        def gradient_end(name)
          ColorPalette.hsl_to_hex((hue(name) + GRADIENT_HUE_SHIFT) % ColorPalette::HUE_RANGE,
                                  @saturation, @lightness)
        end

        # :nodoc:
        def stroke_color(name)
          ColorPalette.hsl_to_hex(hue(name), STROKE_SATURATION, STROKE_LIGHTNESS)
        end

        private

        def hue(name)
          hash = ColorPalette.java_hash(name).abs
          ((hash * ColorPalette::GOLDEN_RATIO % 1.0) * ColorPalette::HUE_RANGE).to_i
        end
      end
    end
  end
end
