module Temple
  module Mixins
    module IndentDispatcher
      def on_indent(exp)
        [:indent, compile(exp)]
      end
    end
  end

  class Filter
    include Mixins::IndentDispatcher
  end
end
