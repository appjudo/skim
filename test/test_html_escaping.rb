require 'helper'

class TestSkimHtmlEscaping < TestSkim
  def test_html_will_not_be_escaped
    source = %q{
p <Hello> World, meet "Skim".
}

    with_and_without_asset do
      assert_html '<p><Hello> World, meet "Skim".</p>', source
    end
  end

  def test_html_with_newline_will_not_be_escaped
    source = %q{
p
  |
    <Hello> World,
     meet "Skim".
}

    with_and_without_asset do
      assert_html "<p><Hello> World,\n meet \"Skim\".</p>", source
    end
  end

  def test_html_with_escaped_interpolation
    source = %q{
- x = '"'
- content = '<x>'
p class="#{x}" test #{content}
}

    with_and_without_asset do
      assert_html '<p class="&quot;">test &lt;x&gt;</p>', source
    end
  end

  def test_html_nested_escaping
    source = %q{
= @callback "Test", -> 'escaped &'
}
    with_and_without_asset do
      assert_html 'Test escaped &amp; Test', source
    end
  end
end
