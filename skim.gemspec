# -*- encoding: utf-8 -*-
require File.expand_path('../lib/skim/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['AppJudo Inc.']
  gem.email         = ['info@appjudo.com']
  gem.description   = %q{Fat-free client-side templates with Slim and CoffeeScript}
  gem.summary       = %q{Take the fat out of your client-side templates with Skim. Skim is the Slim templating engine
with embedded CoffeeScript. It compiles to JavaScript templates (.jst), which can then be served by Rails or any other
Sprockets-based asset pipeline.}
  gem.homepage      = ''

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = 'skim'
  gem.require_paths = ['lib']
  gem.version       = Skim::VERSION
  gem.license       = 'MIT'

  gem.add_dependency "slim", '>= 3.0'
  gem.add_dependency "coffee-script"
  gem.add_dependency "coffee-script-source", ">= 1.2.0"
  gem.add_dependency "sprockets", ">= 2.0", "< 5.0"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "pry"
  gem.add_development_dependency "execjs"
  gem.add_development_dependency "minitest-reporters"
  gem.add_development_dependency "libv8", "~> 8.4"
end
