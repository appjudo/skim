require "sprockets"

Sprockets.register_engine ".skirt", Skim::React::Template

unless defined?(Rails::Engine)
  Sprockets.append_path File.expand_path('../../../vendor/assets/javascripts', __FILE__)
end
