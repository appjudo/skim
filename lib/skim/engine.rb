module Skim
  # Skim engine which transforms slim code to executable ruby code
  # @api public
  class Engine < Temple::Engine
    # This overwrites some Temple default options or sets default options for Slim specific filters.
    # It is recommended to set the default settings only once in the code and avoid duplication. Only use
    # `define_options` when you have to override some default settings.
    define_options :pretty => false,
                   :sort_attrs => true,
                   :attr_quote => '"',
                   :merge_attrs => {'class' => ' '},
                   :encoding => 'utf-8',
                   :generator => Temple::CoffeeScript::Generator,
                   :default_tag => 'div',
                   :use_asset => false

    filter :Encoding
    filter :RemoveBOM
    use Slim::Parser
    use Slim::Embedded
    use Skim::Interpolation
    use Slim::Splat::Filter
    use Skim::Controls
    html :AttributeSorter
    use Temple::CoffeeScript::AttributeMerger
    use Skim::CodeAttributes
    use(:AttributeRemover) { Temple::CoffeeScript::AttributeRemover.new(:remove_empty_attrs => options[:merge_attrs].keys)}
    html :Pretty
    use Temple::HTML::Fast
    use Temple::CoffeeScript::Filters::Escapable
    use Temple::CoffeeScript::Filters::ControlFlow
    filter :MultiFlattener
    use(:Optimizer) { Temple::Filters::StaticMerger.new }
    use :Generator do
      options[:generator].new(options.to_hash.reject {|k,v| !options[:generator].options.valid_keys.include?(k) })
    end
  end
end
