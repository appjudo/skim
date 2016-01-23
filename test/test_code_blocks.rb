require 'helper'

class TestSkimCodeBlocks < TestSkim
  def test_render_with_output_code_block
    source = %q{
p
  = @callback "Hello Ruby!", -> 'Hello from within a block!'
}

    assert_html '<p>Hello Ruby! Hello from within a block! Hello Ruby!</p>', source
  end

  def test_render_with_output_code_within_block
    source = %q{
p
  = @callback "Hello Ruby!", => @callback "Hello from within a block!"
}

    assert_html '<p>Hello Ruby! Hello from within a block! Hello Ruby!</p>', source
  end

  def test_render_with_output_code_within_block_2
    source = %q{
p
  = @callback "Hello Ruby!", => @callback "Hello from within a block!", => @callback "And another one!"
}

    assert_html '<p>Hello Ruby! Hello from within a block! And another one! Hello from within a block! Hello Ruby!</p>', source
  end

  def test_output_block_with_arguments
    source = %q{
p
  = @define_macro 'person', (first_name, last_name) => "<div class=\"first_name\">#{first_name}</div><div class=\"last_name\">#{last_name}</div>"
  == @call_macro 'person', 'John', 'Doe'
  == @call_macro 'person', 'Max', 'Mustermann'
}

    assert_html '<p><div class="first_name">John</div><div class="last_name">Doe</div><div class="first_name">Max</div><div class="last_name">Mustermann</div></p>', source
  end


  def test_render_with_control_code_forEach_loop
    source = %q{
p
  - [0..2].forEach =>
    | Hey!
}

    assert_html '<p>Hey!Hey!Hey!</p>', source
  end

  def test_render_with_control_code_for_in_loop
    source = %q{
p
  - for i in [0..2]
    | Hey!
}

    assert_html '<p>Hey!Hey!Hey!</p>', source
  end

  def test_render_with_control_code_for_in_loop_without_parent
    source = %q{
- for i in [0..2]
  p Hey!
}

    assert_html '<p>Hey!</p><p>Hey!</p><p>Hey!</p>', source
  end

  def test_render_with_control_code_for_own_of_loop
    source = %q{
p
  - for own key, value of {user: 'name'}
    | #{key} #{value}
}

    assert_html '<p>user name</p>', source
  end

  def test_captured_code_block_with_conditional
    source = %q{
= @callback "Hello Ruby!", -> 'Hello from within a block!' if true
}

    assert_html 'Hello Ruby! Hello from within a block! Hello Ruby!', source
  end

  def test_attribute_merger
    source = %q{
.hello class='ruby' Hello Ruby!
}

    assert_html '<div class="hello ruby">Hello Ruby!</div>', source
  end

  def test_attribute_merger_with_not_static_class_attr
    source = %q{
- class_name = 'ruby'
.hello class=class_name Hello Ruby!
}

    assert_html '<div class="hello ruby">Hello Ruby!</div>', source
  end
end