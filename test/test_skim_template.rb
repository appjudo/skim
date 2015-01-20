require 'helper'

class TestSkimTemplate < TestSkim
  def test_registered_extension
    assert_equal Skim::Template, Tilt['test.skim']
  end

  def test_sprockets_integration_without_asset
    compiled = ExecJS.compile(asset_source('test.js'))
    assert_equal "<p>Hello World, meet Skim</p>", compiled.eval("JST.test({name: 'Skim'})")
  end

  def test_sprockets_integration_with_asset
    Skim::Engine.options[:use_asset] = true
    compiled = ExecJS.compile(skim_source + ";" + asset_source('test.js'))
    assert_equal "<p>Hello World, meet Skim</p>", compiled.eval("JST.test({name: 'Skim'})")
  ensure
    Skim::Engine.options[:use_asset] = false
  end

  def test_sprockets_require_directive
    compiled = ExecJS.compile(asset_source('application.js'))
    assert_equal "<p>Hello World, meet Skim</p>", compiled.eval("JST.test({name: 'Skim'})")
  end

  private
  def asset_source(asset_name)
    env = Sprockets::Environment.new
    env.append_path File.dirname(__FILE__)
    env[asset_name].to_s
  end
end
