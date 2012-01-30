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

  def compile(source, options = {})
    Skim::Template.new(options[:file], options) { source }.render
  end

  def evaluate(source, prelude = nil, options = {})
    require "execjs"
    code = [
      prelude,
      "var template = #{compile(source, options)}",
      "var evaluate = function () { return template(new Env()); }"
    ]
    context = ExecJS.compile(code.join(";"))
    context.call("evaluate")
  end

  def render(source, options = {})
    evaluate(source, options[:scope] || @env, options)
  end

  def assert_html(expected, source, options = {}, &block)
    assert_equal expected, render(source, options, &block)
  end
end
