require "rubygems"
require "minitest/unit"
require "skim"
require "coffee_script"

MiniTest::Unit.autorun

class TestSkim < MiniTest::Unit::TestCase
  def env_source
    File.read(File.expand_path("../env.coffee", __FILE__))
  end

  def setup
    @env = CoffeeScript.compile(env_source, :bare => true)
  end

  def env(options)
    if options[:scope]
      MultiJson.encode(options[:scope])
    else
      "new Env()"
    end
  end

  def compile(source, options = {})
    Skim::Template.new(options[:file], options) { source }.render
  end

  def evaluate(source, options = {})
    require "execjs"
    code = [
      @env,
      "var env = #{env(options)}",
      "var template = #{compile(source, options)}",
      "var evaluate = function () { return template(env); }"
    ]
    if options[:use_asset]
      code.unshift CoffeeScript.compile(Skim::Template.skim_src)
    end
    context = ExecJS.compile(code.join(";"))
    context.call("evaluate")
  end

  def render(source, options = {})
    evaluate(source, options)
  end

  def assert_html(expected, source, options = {}, &block)
    assert_equal expected, render(source, options, &block)
  end

  def with_and_without_asset
    [true, false].each do |use_asset|
      yield :use_asset => use_asset
    end
  end

  def assert_runtime_error(message, source, options = {})
    render(source, options)
    raise Exception, 'Runtime error expected'
  rescue RuntimeError => ex
    assert_equal message, ex.message
  end
end
