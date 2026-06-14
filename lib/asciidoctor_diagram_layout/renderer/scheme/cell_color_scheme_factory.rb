module AsciidoctorDiagramLayout
  module Renderer
    module Scheme

      # Creates a {ColorScheme} instance by palette name.
      #
      module CellColorSchemeFactory
        WARM_BASE_HUE        = 30 # :nodoc:
        COOL_BASE_HUE        = 210 # :nodoc:
        ANALOGOUS_HUE_RANGE  = 60 # :nodoc:
        ANALOGOUS_SATURATION = 25 # :nodoc:
        ANALOGOUS_LIGHTNESS  = 86 # :nodoc:
        MONO_HUE             = 210 # :nodoc:
        MONO_SATURATION      = 20 # :nodoc:
        DEFAULT_SATURATION   = 22 # :nodoc:
        DEFAULT_LIGHTNESS    = 88 # :nodoc:
        PDF_SATURATION       = 15 # :nodoc:
        PDF_LIGHTNESS        = 90 # :nodoc:
        PASTEL_SATURATION    = 18 # :nodoc:
        PASTEL_LIGHTNESS     = 93 # :nodoc:

        # Resolves a palette name to a concrete {ColorScheme} instance.
        #
        # @param name [String] palette name:
        #   "rainbow", "pastel", "warm", "cool", "mono", "bw"
        # @param pdf  [Boolean] when +true+ and name is "rainbow", uses
        #   PDF-optimized saturation and lightness
        # @return [ColorScheme]
        # @raise  [ArgumentError] if the name is unknown
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
          when "bw"
            BwScheme.new
          when "rainbow"
            saturation = pdf ? PDF_SATURATION : DEFAULT_SATURATION
            lightness  = pdf ? PDF_LIGHTNESS  : DEFAULT_LIGHTNESS
            GoldenRatioScheme.new(saturation, lightness)
          else
            raise ArgumentError, "Unknown palette: #{key.inspect}"
          end
        end
      end
    end
  end
end
