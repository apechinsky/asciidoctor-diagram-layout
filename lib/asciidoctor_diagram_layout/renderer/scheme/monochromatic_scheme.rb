module AsciidoctorDiagramLayout
  module Renderer
    module Scheme

      # Varies only lightness while keeping hue and saturation fixed.
      #
      # Produces a single-color palette with subtle brightness differences
      # between cells.
      #
      class MonochromaticScheme
        include ColorScheme

        LIGHTNESS_MIN     = 75 # :nodoc:
        LIGHTNESS_MAX     = 95 # :nodoc:
        GRADIENT_SHIFT    = 5  # :nodoc:
        STROKE_LIGHTNESS  = 60 # :nodoc:
        STROKE_SATURATION = 20 # :nodoc:

        # @param hue        [Integer] fixed hue (0..359)
        # @param saturation [Integer] HSL saturation (0..100)
        def initialize(hue, saturation)
          @hue        = hue
          @saturation = saturation
        end

        # :nodoc:
        def fill_color(name)
          ColorPalette.hsl_to_hex(@hue, @saturation, lightness(name))
        end

        # :nodoc:
        def gradient_end(name)
          l = [lightness(name) + GRADIENT_SHIFT, 98].min
          ColorPalette.hsl_to_hex(@hue, @saturation, l)
        end

        # :nodoc:
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
