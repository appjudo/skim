require "rubygems"
require "minitest/unit"
require "minitest/reporters"
require "skim"
require "coffee_script"

if ENV["RM_INFO"] || ENV["TEAMCITY_VERSION"]
  MiniTest::Reporters.use! MiniTest::Reporters::RubyMineReporter.new
else
  MiniTest::Reporters.use! MiniTest::Reporters::ProgressReporter.new
end

MiniTest::Unit.autorun

class TestSkim < MiniTest::Unit::TestCase
  def context_source
    File.read(File.expand_path("../context.coffee", __FILE__))
  end

  def setup
    @context = CoffeeScript.compile(context_source, :bare => true)
  end

  def context(options)
    case context = options[:context]
      when String
        context
      when Hash
        MultiJson.encode(context)
      else
        "new Context()"
    end
  end

  def compile(source, options = {})
    Skim::Template.new(options[:file], options) { source }.render(options[:scope] || Env.new)
  end

  def evaluate(source, options = {})
    require "execjs"
    code = [
      @context,
      "var context  = #{context(options)}",
      "var template = #{compile(source, options)}",
      "var evaluate = function () { return template(context); }"
    ]
    if Skim::Engine.default_options[:use_asset]
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
    yield

    begin
      Skim::Engine.default_options[:use_asset] = true
      yield
    ensure
      Skim::Engine.default_options[:use_asset] = false
    end
  end

  def assert_runtime_error(message, source, options = {})
    render(source, options)
    raise Exception, 'Runtime error expected'
  rescue RuntimeError => ex
    assert_equal message, ex.message
  end
end

class Env
  def hello_world(text = "Hello World from @env", opts = {})
    text << opts.to_a * " " if opts.any?
    if block_given?
      "#{text} #{yield} #{text}"
    else
      text
    end
  end
end
