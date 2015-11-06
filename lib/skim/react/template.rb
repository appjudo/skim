module Skim
  module React
    Template = Temple::Templates::Tilt(Skim::React::Engine, :register_as => :skirt)
    Skim::TemplateInjector.inject(Template)

    class Template

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
  Skim.withContext.call {}, context, ->
#{src}
SRC
      end
    end
  end
end
