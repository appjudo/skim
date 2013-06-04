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

    filter :Encoding, :encoding
    filter :RemoveBOM
    use Slim::Parser, :file, :tabsize, :shortcut, :default_tag
    use Slim::Embedded, :enable_engines, :disable_engines, :pretty
    use Skim::Interpolation
    use Slim::Splat::Filter, :merge_attrs, :attr_quote, :sort_attrs, :default_tag, :hyphen_attrs
    use Skim::Controls, :disable_capture
    html :AttributeSorter, :sort_attrs
    html :AttributeMerger, :merge_attrs
    use Skim::CodeAttributes, :merge_attrs
    use(:AttributeRemover) { Temple::CoffeeScript::AttributeRemover.new(:remove_empty_attrs => options[:merge_attrs].keys)}
    html :Pretty, :format, :attr_quote, :pretty, :indent, :js_wrapper
    use Temple::HTML::Fast, :format, :attr_quote
    use Temple::CoffeeScript::Filters::Escapable, :use_html_safe, :disable_escape
    use Temple::CoffeeScript::Filters::ControlFlow
    filter :MultiFlattener
    use(:Optimizer) { Temple::Filters::StaticMerger.new }
    use :Generator do
      options[:generator].new(options.to_hash.reject {|k,v| !options[:generator].default_options.valid_keys.include?(k) })
    end
  end
end
