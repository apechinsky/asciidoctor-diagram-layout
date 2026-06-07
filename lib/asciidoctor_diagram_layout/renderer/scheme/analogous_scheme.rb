module AsciidoctorDiagramLayout
  module Renderer
    module Scheme
      class AnalogousScheme
        GRADIENT_HUE_SHIFT = 15
        STROKE_LIGHTNESS   = 65
        STROKE_SATURATION  = 25

        def initialize(base_hue, hue_range, saturation, lightness)
          @base_hue   = base_hue
          @hue_range  = hue_range
          @saturation = saturation
          @lightness  = lightness
        end

        def fill_color(name)
          ColorPalette.hsl_to_hex(hue(name), @saturation, @lightness)
        end

        def gradient_end(name)
          ColorPalette.hsl_to_hex((hue(name) + GRADIENT_HUE_SHIFT) % ColorPalette::HUE_RANGE,
                                  @saturation, @lightness)
        end

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
