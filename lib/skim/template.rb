require "coffee-script"

module Skim
  Template = Temple::Templates::Tilt(Skim::Engine, :register_as => :skim)

  class Template
    self.default_mime_type = "application/javascript"

    def self.call(input)
      source   = input[:data]
      context  = input[:environment].context_class.new(input)

      result = new { source }.render
      context.metadata.merge(data: result)
    end

    def coffee_script_src

      engine = Engine.new(options.merge({
        :streaming => false, # Overwrite option: No streaming support in Tilt
        :file => eval_file,
        :indent => 2
      }))
      src = engine.call(data)
<<-SRC
#{self.class.skim_src unless engine.options[:use_asset]}
return (context = {}) ->
  (context.Skim || Skim).withContext.call {}, context, ->
#{src}
SRC
    end

    def prepare
      @src = CoffeeScript.compile(coffee_script_src)
    end

    def evaluate(scope, locals, &block)
      precompiled_template
    end

    def self.skim_src
      @@skim_src ||=
        File.read(File.expand_path("../../../vendor/assets/javascripts/skim.js.coffee", __FILE__))
    end
  end
end
