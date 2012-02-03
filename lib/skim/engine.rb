module Skim
  class Engine < Temple::Engine
    set_default_options :pretty => false,
                        :attr_wrapper => '"',
                        :attr_delimiter => {'class' => ' '},
                        :generator => Temple::CoffeeScript::Generator

    use Slim::Parser, :file, :tabsize, :encoding, :default_tag
    use Slim::EmbeddedEngine, :enable_engines, :disable_engines, :pretty
    use Slim::Interpolation
    use Skim::Sections, :sections
    use Skim::Compiler, :disable_capture, :attr_delimiter
    use Temple::CoffeeScript::AttributeMerger, :attr_delimiter
    use Temple::HTML::AttributeSorter
    use Temple::CoffeeScript::AttributeRemover
    use Temple::HTML::Fast, :format, :attr_wrapper
    use Temple::CoffeeScript::Filters::Escapable, :disable_escape
    use Temple::CoffeeScript::Filters::ControlFlow
    filter :MultiFlattener
    use(:Optimizer) { Temple::Filters::StaticMerger.new }
    use(:Generator) { options[:generator].new(options) }
  end
end
