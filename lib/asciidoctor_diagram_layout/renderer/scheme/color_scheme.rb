module AsciidoctorDiagramLayout
  module Renderer

    # Color scheme DSL and implementations.
    #
    module Scheme
      # Defines the duck-type contract for color scheme objects.
      #
      # Every concrete scheme must include this module and override all three
      # methods.  Calling an unimplemented method raises +NotImplementedError+
      # with the name of the offending class.
      #
      # @example Minimal implementation (black-and-white)
      #   class BwScheme
      #     include ColorScheme
      #
      #     FILL_COLOR = "#ffffff"
      #
      #     def fill_color(_name)   = FILL_COLOR
      #     def gradient_end(name) = fill_color(name)
      #     def stroke_color(_name) = "#000000"
      #   end
      #
      module ColorScheme
        # Returns the base fill color for a named cell.
        #
        # @param name [String] cell name, used to derive a color from its hash
        # @return [String] hex color string (e.g. "#d4d4d4")
        def fill_color(name)
          raise NotImplementedError, "#{self.class} must implement #fill_color"
        end

        # Returns the gradient endpoint color for a named cell.
        #
        # When this equals +#fill_color+ the gradient is imperceptible,
        # producing a visually flat fill.
        #
        # @param name [String] cell name
        # @return [String] hex color string
        def gradient_end(name)
          raise NotImplementedError, "#{self.class} must implement #gradient_end"
        end

        # Returns the stroke (border) color for a named cell.
        #
        # @param name [String] cell name
        # @return [String] hex color string
        def stroke_color(name)
          raise NotImplementedError, "#{self.class} must implement #stroke_color"
        end
      end
    end
  end
end
