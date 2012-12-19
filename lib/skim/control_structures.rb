module Skim
  class ControlStructures < Slim::ControlStructures
    def on_slim_control(code, content)
      [:multi,
        [:code, code],
        [:indent, compile(content)]]
    end
  end
end
