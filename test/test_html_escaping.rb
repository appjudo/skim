require 'helper'

class TestSkimHtmlEscaping < TestSkim
  def test_html_will_not_be_escaped
    source = %q{
p <Hello> World, meet "Skim".
}

    assert_html '<p><Hello> World, meet "Skim".</p>', source
  end

  def test_html_with_newline_will_not_be_escaped
    source = %q{
p
  |
    <Hello> World,
     meet "Skim".
}

    assert_html "<p><Hello> World,\n meet \"Skim\".</p>", source
  end

  def test_html_with_escaped_interpolation
    source = %q{
- x = '"'
- content = '<x>'
p class="#{x}" test #{content}
}

    assert_html '<p class="&quot;">test &lt;x&gt;</p>', source
  end

  def test_html_nested_escaping
    source = %q{
= @callback "Test", ->
  | escaped &
}
    assert_html 'Test escaped &amp; Test', source
  end
end
