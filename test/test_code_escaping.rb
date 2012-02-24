require 'helper'

class TestSkimCodeEscaping < TestSkim
  def test_escaping_evil_method
    source = %q{
p = @evil_method()
}

    assert_html '<p>&lt;script&gt;do_something_evil();&lt;&#47;script&gt;</p>', source
  end

  def test_render_unsafe
    source = %q{
p = "<strong>Hello World\\n, meet \\"Skim\\"</strong>."
}

    assert_html "<p>&lt;strong&gt;Hello World\n, meet \&quot;Skim\&quot;&lt;&#47;strong&gt;.</p>", source
  end

  def test_render_safe
    source = %q{
p = Skim.safe("<strong>Hello World\\n, meet \\"Skim\\"</strong>.")
}

    assert_html "<p><strong>Hello World\n, meet \"Skim\"</strong>.</p>", source
  end

  def test_render_with_disable_escape_false
    source = %q{
= "<p>Hello</p>"
== "<p>World</p>"
}

    assert_html "&lt;p&gt;Hello&lt;&#47;p&gt;<p>World</p>", source
  end

  def test_render_with_disable_escape_true
    source = %q{
= "<p>Hello</p>"
== "<p>World</p>"
}

    assert_html "<p>Hello</p><p>World</p>", source, :disable_escape => true
  end
end
