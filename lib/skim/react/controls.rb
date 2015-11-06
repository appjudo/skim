module Skim
  module React
    class Controls < Skim::Controls
      def on_slim_control(code, content)
        [:multi,
          [:code, code],
          [:indent, compile(content)]
        ]
      end

      def on_slim_output(escape, code, content)
        skim_text(super)
      end
      
      def on_slim_text(type, content)
        skim_text(super)
      end

      protected

      def skim_text(exp)
        [:multi, [:code, '@skimText('], exp, [:code, ')'], [:newline]]
      end
    end
  end
end