module AsciidoctorDiagramLayout
  module Renderer
    module Scheme
      class MonochromaticScheme
        LIGHTNESS_MIN      = 75
        LIGHTNESS_MAX      = 95
        GRADIENT_SHIFT     = 5
        STROKE_LIGHTNESS   = 60
        STROKE_SATURATION  = 20

        def initialize(hue, saturation)
          @hue        = hue
          @saturation = saturation
        end

        def fill_color(name)
          ColorPalette.hsl_to_hex(@hue, @saturation, lightness(name))
        end

        def gradient_end(name)
          l = [lightness(name) + GRADIENT_SHIFT, 98].min
          ColorPalette.hsl_to_hex(@hue, @saturation, l)
        end

        def stroke_color(name)
          ColorPalette.hsl_to_hex(@hue, STROKE_SATURATION, STROKE_LIGHTNESS)
        end

        private

        def lightness(name)
          hash = ColorPalette.java_hash(name).abs
          range = LIGHTNESS_MAX - LIGHTNESS_MIN
          LIGHTNESS_MIN + (hash % (range + 1))
        end
      end
    end
  end
end
