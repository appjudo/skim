module Temple
  module Mixins
    module IndentDispatcher
      def on_indent(exp)
        [:indent, compile(exp)]
      end
    end

    module Dispatcher
      include IndentDispatcher
    end
  end
end
