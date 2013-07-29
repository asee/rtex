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
    alias :l :latex_escape
  end
end
