module Temple
  module CoffeeScript
    module Filters
      class Escapable < Filter
        # Activate the usage of html_safe? if it is available (for Rails 3 for example)
        define_options :escape_code,
                       :use_html_safe => ''.respond_to?(:html_safe?),
                       :disable_escape => false

        def initialize(opts = {})
          super
          @escape_code = options[:escape_code] ||
            "::Temple::Utils.escape_html#{options[:use_html_safe] ? '_safe' : ''}((%s))"
          @escaper = eval("proc {|v| #{@escape_code % 'v'} }")
          @escape = false
        end

        def on_escape(flag, exp)
          old = @escape
          @escape = flag && !options[:disable_escape]
          compile(exp)
        ensure
          @escape = old
        end

        def on_static(value)
          [:static, @escape ? @escaper[value] : value]
        end

        def on_dynamic(value)
          [:dynamic, @escape ? "@escape(#{value})" : value]
        end
      end
    end
  end
end
