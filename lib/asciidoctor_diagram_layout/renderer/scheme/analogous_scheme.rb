module AsciidoctorDiagramLayout
  module Renderer
    module Scheme

      # Varies hue within a limited range around a base hue.
      #
      # Produces visually harmonious palettes (warm or cool) where colors
      # are adjacent on the color wheel.
      #
      class AnalogousScheme
        include ColorScheme

        GRADIENT_HUE_SHIFT = 15 # :nodoc:
        STROKE_LIGHTNESS   = 65 # :nodoc:
        STROKE_SATURATION  = 25 # :nodoc:

        # @param base_hue   [Integer] center hue (0..359)
        # @param hue_range  [Integer] total spread in degrees
        # @param saturation [Integer] HSL saturation (0..100)
        # @param lightness  [Integer] HSL lightness  (0..100)
        def initialize(base_hue, hue_range, saturation, lightness)
          @base_hue   = base_hue
          @hue_range  = hue_range
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
          offset = (hash * ColorPalette::GOLDEN_RATIO % 1.0) * @hue_range
          (@base_hue + offset.to_i) % ColorPalette::HUE_RANGE
        end
      end
    end
  end
end
