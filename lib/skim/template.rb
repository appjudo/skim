module Skim
  Template = Temple::Templates::Tilt(Skim::Engine, :register_as => :skim)

  class Template
    def coffee_script_src
      engine = self.class.build_engine({
        :streaming => false, # Overwrite option: No streaming support in Tilt
        :file => eval_file,
        :indent => 2 }, options)
      <<SRC
return (context = {}) ->
  #{self.class.skim_src unless engine.options[:use_asset]}
  (()->
#{engine.call(data)}
  ).call(context)
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
