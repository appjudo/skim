module Skim
  module React
    class Engine < Temple::Engine
      # This overwrites some Temple default options or sets default options for Slim specific filters.
      # It is recommended to set the default settings only once in the code and avoid duplication. Only use
      # `define_options` when you have to override some default settings.
      define_options :pretty => false,
                     :sort_attrs => true,
                     :attr_quote => '"',
                     :merge_attrs => {'class' => ' '},
                     :encoding => 'utf-8',
                     :generator => Skim::React::Generator,
                     :default_tag => 'div',
                     :use_asset => false,
                     :indent => 0

      filter :Encoding
      filter :RemoveBOM
      use Slim::Parser
      use Slim::Embedded
      use Skim::React::Interpolation
      use Slim::Splat::Filter
      use Skim::React::Controls
      html :AttributeSorter
      html :AttributeMerger
      use Temple::CoffeeScript::AttributeMerger
      use Skim::React::CodeAttributes
      # use(:AttributeRemover) { Temple::CoffeeScript::AttributeRemover.new(:remove_empty_attrs => options[:merge_attrs].keys)}
      # html :Pretty
      # use Temple::HTML::Fast
      use Skim::React::HTMLFilter
      use Temple::CoffeeScript::Filters::Escapable
      use Temple::CoffeeScript::Filters::ControlFlow
      filter :MultiFlattener
      use(:Optimizer) { Temple::Filters::StaticMerger.new }
      use :Generator do
        options[:generator].new(options.to_hash.reject {|k,v| !options[:generator].options.valid_keys.include?(k) })
      end
    end
  end
end
