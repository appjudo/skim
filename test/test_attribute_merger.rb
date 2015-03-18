require 'helper'

class TestAttributeMerger < Minitest::Test
  def call(expr)
    Temple::CoffeeScript::AttributeMerger.new.call(expr)
  end

  def test_passes_single_attributes
    sexp = [:html, :attrs,
            [:html, :attr, "foo", [:static, "a"]],
            [:html, :attr, "bar", [:static, "b"]]]
    assert_equal sexp, call(sexp)
  end

  def test_merges_multiple_attributes
    sexp = [:html, :attrs,
            [:html, :attr, "class", [:static, "a"]],
            [:html, :attr, "class", [:static, "b"]]]
    assert_equal [:html, :attrs,
                  [:html, :attr, "class",
                   [:multi, [:static, "a"], [:static, " "], [:static, "b"]]]], call(sexp)
  end
end
