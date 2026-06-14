module AsciidoctorDiagramLayout
  module Renderer
    module Scheme

      # Black-and-white scheme — solid white fill, black stroke, no visible gradient.
      #
      class BwScheme
        include ColorScheme

        FILL_COLOR   = "#ffffff"   # :nodoc:
        STROKE_COLOR = "#000000"   # :nodoc:

        # :nodoc:
        def fill_color(_name)
          FILL_COLOR
        end

        # :nodoc:
        def gradient_end(name)
          fill_color(name)
        end

        # :nodoc:
        def stroke_color(_name)
          STROKE_COLOR
        end
      end
    end
  end
end
