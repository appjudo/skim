require "temple"
require "temple/coffee_script"

require "slim"
require "skim/compiler"
require "skim/engine"
require "skim/template"
require "skim/version"

require "sprockets"
Sprockets.register_engine ".skim", Skim::Template
