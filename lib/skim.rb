require "temple"
require "temple/coffee_script"

require "slim"
require "skim/controls"
require "skim/code_attributes"
require "skim/interpolation"
require "skim/engine"
require "skim/template"
require "skim/version"

require "skim/rails" if Object.const_defined?(:Rails)

require "sprockets"
Sprockets::Engines # force autoload
Sprockets.register_engine ".skim", Skim::Template
