module AsciidoctorDiagramLayout
  module Renderer
    module Scheme
      module CellColorSchemeFactory
        WARM_BASE_HUE        = 30
        COOL_BASE_HUE        = 210
        ANALOGOUS_HUE_RANGE  = 60
        ANALOGOUS_SATURATION = 25
        ANALOGOUS_LIGHTNESS  = 86
        MONO_HUE             = 210
        MONO_SATURATION      = 20
        DEFAULT_SATURATION   = 22
        DEFAULT_LIGHTNESS    = 88
        PDF_SATURATION       = 15
        PDF_LIGHTNESS        = 90
        PASTEL_SATURATION    = 18
        PASTEL_LIGHTNESS     = 93

        def self.resolve(name, pdf: false)
          key = name.to_s.downcase
          case key
          when "pastel"
            GoldenRatioScheme.new(PASTEL_SATURATION, PASTEL_LIGHTNESS)
          when "warm"
            AnalogousScheme.new(WARM_BASE_HUE, ANALOGOUS_HUE_RANGE, ANALOGOUS_SATURATION, ANALOGOUS_LIGHTNESS)
          when "cool"
            AnalogousScheme.new(COOL_BASE_HUE, ANALOGOUS_HUE_RANGE, ANALOGOUS_SATURATION, ANALOGOUS_LIGHTNESS)
          when "mono"
            MonochromaticScheme.new(MONO_HUE, MONO_SATURATION)
          else
            pdf ? GoldenRatioScheme.new(PDF_SATURATION, PDF_LIGHTNESS)
                : GoldenRatioScheme.new(DEFAULT_SATURATION, DEFAULT_LIGHTNESS)
          end
        end
      end
    end
  end
end
