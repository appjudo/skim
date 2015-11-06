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

require "skim/react/code_attributes"
require "skim/react/controls"
require "skim/react/interpolation"
require "skim/react/html_filter"
require "skim/react/generator"
require "skim/react/engine"
require "skim/react/template"
require "skim/react/sprockets"
