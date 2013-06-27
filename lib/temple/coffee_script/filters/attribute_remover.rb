module Temple
  module CoffeeScript
    class AttributeRemover < Temple::HTML::AttributeRemover
      include Temple::HTML::Dispatcher

      define_options :remove_empty_attrs => %w(id class)

      def on_html_attr(name, value)
        return super unless options[:remove_empty_attrs].include?(name.to_s)

        if empty_exp?(value)
          value
        elsif contains_nonempty_static?(value)
          [:html, :attr, name, value]
        else
          tmp = unique_name
          [:multi,
           [:capture, tmp, compile(value)],
           [:if, "#{tmp}.length > 0",
            [:html, :attr, name, [:dynamic, tmp]]]]
        end
      end
    end
  end
end
