module Skim
  class Controls < Slim::Controls
    def on_slim_control(code, content)
      [:multi,
        [:code, code],
        [:indent, compile(content)]]
    end
  end
end
