require "json"

module Temple
  module CoffeeScript
    class Generator < Temple::Generator
      define_options :indent => 0

      def call(exp)
        @indent = options[:indent]
        compile [:multi, [:code, "#{buffer} = ''"], exp, [:code, "#{buffer}"]]
      end

      def on_multi(*exp)
        exp.map {|e| compile(e) }.join("\n")
      end

      def on_static(text)
        concat(JSON.generate(text, :quirks_mode => true))
      end

      def on_dynamic(code)
        concat(code)
      end

      def on_code(code)
        indent(code)
      end

      def on_indent(exp)
        @indent += 1
        compile(exp)
      ensure
        @indent -= 1
      end

      def on_capture(name, exp)
        self.class.new(:buffer => name, :indent => @indent).call(exp)
      end

      def concat(str)
        indent "#{buffer} += #{str}"
      end

      def indent(str, indent = @indent)
        "  " * indent + str
      end
    end
  end
end
