module AsciidoctorDiagramLayout
  module Renderer
    module Scheme
      class GoldenRatioScheme
        GRADIENT_HUE_SHIFT = 20
        STROKE_LIGHTNESS   = 65
        STROKE_SATURATION  = 30

        def initialize(saturation, lightness)
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
          ((hash * ColorPalette::GOLDEN_RATIO % 1.0) * ColorPalette::HUE_RANGE).to_i
        end
      end
    end
  end
end
