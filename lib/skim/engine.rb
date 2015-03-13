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

    filter :Encoding, {:encoding => 'utf-8'}
    filter :RemoveBOM
		use Slim::Parser, {:default_tag => 'div'}
    use Slim::Embedded, {:pretty => false}
    use Skim::Interpolation
    use Slim::Splat::Filter, {:merge_attrs => {'class' => ' '}, :attr_quote => '"', :sort_attrs => true, :default_tag => 'div'}
    use Skim::Controls, {:disable_capture => nil}
    html :AttributeSorter, {:sort_attrs => true}
    use Temple::CoffeeScript::AttributeMerger, {:merge_attrs => {'class' => ' '}}
    use Skim::CodeAttributes, {:merge_attrs => {'class' => ' '}}
    use(:AttributeRemover) { Temple::CoffeeScript::AttributeRemover.new(:remove_empty_attrs => options[:merge_attrs].keys)}
    html :Pretty, {:attr_quote => '"', :pretty => false}
    use Temple::HTML::Fast, {:attr_quote => '"'}
    use Temple::CoffeeScript::Filters::Escapable, {} 
    use Temple::CoffeeScript::Filters::ControlFlow
    filter :MultiFlattener
    use(:Optimizer) { Temple::Filters::StaticMerger.new }
    use :Generator do
      options[:generator].new(options.to_hash.reject {|k,v| !options[:generator].options.valid_keys.include?(k) })
    end
  end
end

