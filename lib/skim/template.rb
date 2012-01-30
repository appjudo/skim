module Skim
  Template = Temple::Templates::Tilt(Skim::Engine, :register_as => :skim)

  class Template
    def coffee_script_src
      <<SRC
(context = {}) ->
  context.safe ||= (value) ->
    return value if value?.skimSafe
    result = new String(value ? '')
    result.skimSafe = true
    result

  context.escape ||= (string) ->
    return '' unless string?
    return string if string.skimSafe
    (''+string)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/\\//g,'&#47;')

  (->
#{self.class.build_engine({ :streaming => false, # Overwrite option: No streaming support in Tilt
                            :file => eval_file,
                            :indent => 2 }, options).call(data)}
  ).call(context)
SRC
    end

    def prepare
      @src = CoffeeScript.compile(coffee_script_src, :bare => true)
    end

    def evaluate(scope, locals, &block)
      precompiled_template
    end
  end
end
