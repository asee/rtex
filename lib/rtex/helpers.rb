module RTeX
  module Helpers
    def latex_escape(*args)
      # Since Rails' I18n implementation aliases l() to localize(), LaTeX
      # escaping should only be done if RTeX is doing the rendering.
      # Otherwise, control should be be passed to localize().
      if Thread.current[:_rendering_rtex]
        RTeX::Document.escape(*args)
      else
        localize(*args)
      end
    end

    def latex_simple_format(*args)
      RTeX::Document.simple_format(*args)
    end

    alias :l :latex_escape
    alias :sf :latex_simple_format

  end
end
