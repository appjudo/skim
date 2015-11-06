module Skim
  module React
    class Generator < Temple::CoffeeScript::Generator
      INDENT = '  '

      define_options :indent => 0

      def call(exp)
        @indent = options[:indent]
        indent + compile([:multi, exp, [:newline], [:code, "@skimReact()"]])
      end

      def on_newline
        "\n" + indent
      end

      def on_multi(*exp)
        exp.map {|e| compile(e) }.join('')
      end

      def on_static(text)
        concat(JSON.generate(text, :quirks_mode => true))
      end

      def on_dynamic(code)
        concat(code)
      end

      def on_code(code)
        code
        # indent(code)
      end

      def on_indent(exp)
        newline = on_newline
        @indent += 1
        INDENT + compile(exp).sub(/\s+\Z/, '') + newline
      ensure
        @indent -= 1
      end

      def on_capture(name, exp)
        self.class.new(:buffer => name, :indent => @indent).call(exp)
      end

      def concat(str)
        str
        # indent(str)
      end

      def indent
        INDENT * @indent
      end

      # def indent(str, indent = @indent)
      #   "  " * indent + str
      # end

      def on_inline(exp)
        exp
      end

      def inline(str)
        str
      end
    end
  end
end
