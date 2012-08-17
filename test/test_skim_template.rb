require 'helper'

class TestSkimTemplate < TestSkim
  def test_registered_extension
    assert_equal Skim::Template, Tilt['test.skim']
  end

  def test_sprockets_integration_without_asset
    compiled = ExecJS.compile(template_source)
    assert_equal "<p>Hello World, meet Skim</p>", compiled.eval("JST.test({name: 'Skim'})")
  end

  def test_sprockets_integration_with_asset
    Skim::Engine.default_options[:use_asset] = true
    compiled = ExecJS.compile(skim_source + ";" + template_source)
    assert_equal "<p>Hello World, meet Skim</p>", compiled.eval("JST.test({name: 'Skim'})")
  ensure
    Skim::Engine.default_options[:use_asset] = false
  end

  private
  def template_source
    env = Sprockets::Environment.new
    env.append_path File.dirname(__FILE__)
    env['test.js'].to_s
  end
end
