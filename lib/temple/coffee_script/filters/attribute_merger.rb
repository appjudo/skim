module Temple
  module CoffeeScript
    class AttributeMerger < Filter
      include Temple::HTML::Dispatcher

      define_options :merge_attrs => {'id' => '_', 'class' => ' '}

      def on_html_attrs(*attrs)
        names = []
        result = {}

        attrs.each do |html, attr, name, value|
          raise(InvalidExpression, 'Attribute is not a html attr') if html != :html || attr != :attr
          name = name.to_s
          if delimiter = options[:merge_attrs][name]
            if current = result[name]
              current << [:static, delimiter] << value
            else
              result[name] = [:multi, value]
              names << name
            end
          else
            raise "Multiple #{name} attributes specified" if result[name]
            result[name] = value
            names << name
          end
        end

        [:html, :attrs, *names.map {|name| [:html, :attr, name, result[name]]}]
      end
    end
  end
end
