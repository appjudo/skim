require "temple"
require "temple/coffee_script"

require "slim"
require "skim/controls"
require "skim/code_attributes"
require "skim/interpolation"
require "skim/engine"
require "skim/template"
require "skim/version"

require "skim/rails" if defined?(Rails::Engine)
require "skim/sprockets"
