module Skim
  class Compiler < Slim::Compiler
    def on_slim_control(code, content)
      [:multi,
        [:code, code],
        [:indent, compile(content)]]
    end

    def on_slim_attr(name, escape, code)
      value = case code
      when 'true'
        escape = false
        [:static, name]
      when 'false', 'null'
        escape = false
        [:multi]
      else
        tmp = unique_name
        [:multi,
         [:code, "#{tmp} = #{code}"],
         [:case, tmp,
          ['true', [:static, name]],
          ['false, null', [:multi]],
          [:else,
           [:dynamic,
            #if delimiter = options[:attr_delimiter][name]
            #  "#{tmp}.respond_to?(:join) ? #{tmp}.flatten.compact.join(#{delimiter.inspect}) : #{tmp}"
            #else
              tmp
            #end
           ]]]]
      end
      [:html, :attr, name, [:escape, escape, value]]
    end
  end
end
