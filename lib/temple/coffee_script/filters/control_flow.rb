module Temple
  module CoffeeScript
    module Filters
      class ControlFlow < Filter
        def on_if(condition, yes, no = nil)
          result = [:multi, [:code, "if #{condition}"], [:indent, compile(yes)]]
          while no && no.first == :if
            result << [:code, "else if #{no[1]}"] << [:indent, compile(no[2])]
            no = no[3]
          end
          result << [:code, 'else'] << [:indent, compile(no)] if no
          result
        end

        def on_case(arg, *cases)
          result = [:multi, [:code, arg ? "switch (#{arg})" : 'switch'], [:indent, [:multi]]]
          cases.map do |c|
            condition, *exps = c
            result[2][1] << [:code, condition == :else ? 'else' : "when #{condition}"]
            exps.each {|e| result[2][1] << [:indent, compile(e)] }
          end
          result
        end

        def on_cond(*cases)
          on_case(nil, *cases)
        end

        def on_block(code, exp)
          [:multi,
           [:code, code],
           [:indent, compile(exp)]]
        end
      end
    end
  end
end
