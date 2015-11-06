module Skim
  module React
    class HTMLFilter < Temple::HTML::Fast
      def on_html_comment(content)
        [:code, "/* #{content} */"]
      end

      def on_html_condcomment(condition, content)
        on_html_comment content
      end

      def on_html_tag(name, attrs, content = nil)
        name = name.to_s
        closed = !content || (empty_exp?(content) && (@format == :xml || options[:autoclose].include?(name)))
        result = [compile(attrs)]
        if content && content != [:multi, [:newline]]
          result << [:multi, [:code, ', ->'], [:newline], [:indent, [:multi, compile(content), [:code, 'return']]]]
        end
        name = name.gsub('-', '.')
        if /[[:lower:]]/.match(name[0])
          name = "'#{name}'"
        end
        [:multi,
          [:code, "@skimElement #{name}, "],
          *result, [:newline]
        ]
      end

      def on_html_attrs(*attrs)
        @in_attrs = true
        result = []
        if attrs.empty?
          return [:code, 'null']
        end
        attrs.each do |attr|
          result.push compile(attr)
        end
        @in_attrs = false
        [:multi, [:code, '{'], [:indent, [:multi, *result]], [:code, '}']]
      end

      def on_html_attr(name, value)
        if name == 'class'
          name = 'className'
        end
        result = [:multi, [:newline]]
        if name == 'style'
          declaration_block = value[2][1][1]
          result << [:code, "'style': { " +
            declaration_block.split(/\s*\;\s*/).map do |declaration|
              property, value = declaration.split(/\s*\:\s*/)
              property = property.gsub(/-(\w)/) {$1.upcase}
              "#{property}: '#{value}'"
            end.join(', ') + ' }'
          ]
        elsif @format == :html && empty_exp?(value)
          result << [:code, "'#{name}': true"]
        else
          result += [[:code, "'#{name}': "], compile(value)]
        end
        result
      end
    end
  end
end
