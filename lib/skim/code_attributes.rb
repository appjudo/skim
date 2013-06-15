module Skim
  class CodeAttributes < Slim::Filter
    define_options :merge_attrs

    # Handle attributes expression `[:html, :attrs, *attrs]`
    #
    # @param [Array] attrs Array of temple expressions
    # @return [Array] Compiled temple expression
    def on_html_attrs(*attrs)
      [:multi, *attrs.map {|a| compile(a) }]
    end

    # Handle attribute expression `[:html, :attr, name, value]`
    #
    # @param [String] name Attribute name
    # @param [Array] value Value expression
    # @return [Array] Compiled temple expression
    def on_html_attr(name, value)
      if value[0] == :slim && value[1] == :attrvalue && !options[:merge_attrs][name]
        # We handle the attribute as a boolean attribute
        escape, code = value[2], value[3]
        case code
        when 'true'
          [:html, :attr, name, [:static, name]]
        when 'false', 'null'
          [:multi]
        else
          tmp = unique_name
          [:multi,
           [:code, "#{tmp} = #{code}"],
           [:case, tmp,
            ['true', [:html, :attr, name, [:static, name]]],
            ['false, null', [:multi]],
            [:else, [:html, :attr, name, [:escape, escape, [:dynamic, tmp]]]]]]
        end
      else
        # Attribute with merging
        @attr = name
        return super
      end
    end

    # Handle attribute expression `[:slim, :attrvalue, escape, code]`
    #
    # @param [Boolean] escape Escape html
    # @param [String] code Ruby code
    # @return [Array] Compiled temple expression
    def on_slim_attrvalue(escape, code)
      # We perform attribute merging on Array values
      if delimiter = options[:merge_attrs][@attr]
        tmp = unique_name
        [:multi,
         [:code, "#{tmp} = #{code}"],
         [:if, "@isArray(#{tmp})",
          [:multi,
           [:code, "#{tmp} = @flatten(#{tmp})"],
           [:code, "#{tmp} = item.toString() for item in #{tmp} when item"],
           [:code, "#{tmp} = item for item in #{tmp} when item.length > 0"],
           [:escape, escape, [:dynamic, "#{tmp}.join(#{delimiter.inspect})"]]],
          [:escape, escape, [:dynamic, tmp]]]]
      else
        [:escape, escape, [:dynamic, code]]
      end
    end
  end
end