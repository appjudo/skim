require "multi_json"

module Skim
  class Sections < Slim::Sections
    def call(exp)
      if options[:sections]
        compile(exp)
      else
        exp
      end
    end

    protected

    def on_slim_inverted_section(name, content)
      [:if, "not #{access(name)}", compile(content)]
    end

    def on_slim_section(name, content)
      tmp1, tmp2 = unique_name, unique_name
      [:if, "#{tmp1} = #{access(name)}",
        [:block, "for #{tmp2} in #{tmp1}",
          [:multi,
            [:code, "(->"],
            [:indent, compile(content)],
            [:code, ").call(#{tmp2})"]
          ]
        ]
      ]
    end

    private

    def access(name)
      "Skim.access.call(@, #{MultiJson.encode(name.to_s)})"
    end
  end
end
