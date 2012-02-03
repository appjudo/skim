require 'helper'

class TestSkimLogicLess < TestSkim
  def test_sections
    source = %q{
p
 - person
  .name = name
}

    hash = {
      :person => [
        { :name => 'Joe', },
        { :name => 'Jack', }
      ]
    }

    assert_html '<p><div class="name">Joe</div><div class="name">Jack</div></p>', source, :scope => hash, :sections => true
  end

  def test_flag_section
    source = %q{
p
 - show_person
   - person
    .name = name
 - show_person
   | shown
}

    hash = {
      :show_person => true,
      :person => [
        { :name => 'Joe', },
        { :name => 'Jack', }
      ]
    }

    assert_html '<p><div class="name">Joe</div><div class="name">Jack</div>shown</p>', source, :scope => hash, :sections => true
  end

  def test_inverted_section
    source = %q{
p
 - person
  .name = name
 -! person
  | No person
 - !person
  |  No person 2
}

    hash = {}

    assert_html '<p>No person No person 2</p>', source, :scope => hash, :sections => true
  end

  def test_output_with_content
    source = %{
p = method_with_block do
  block
}
    assert_runtime_error 'Output statements with content are forbidden in sections mode', source, :sections => true
  end

  def test_sections2
    source = %q{
p
 - person
  .name = name
}
    assert_html '<p><div class="name">Joe</div><div class="name">Jack</div></p>', source, :sections => true
  end

  def test_with_array
    source = %q{
ul
 - people_with_locations
  li = name
  li = city
}
    assert_html '<ul><li>Andy</li><li>Atlanta</li><li>Fred</li><li>Melbourne</li><li>Daniel</li><li>Karlsruhe</li></ul>', source, :sections => true
  end

  def test_method
    source = %q{
a href=output_number Link
}
    assert_html '<a href="1337">Link</a>', source, :sections => true
  end

  SECTION = <<-SRC
- test
  | Test
  SRC

  INVERTED_SECTION = <<-SRC
-! test
  | Test
  SRC

  def test_undefined_section
    assert_html "", SECTION, :scope => {}, :sections => true
  end

  def test_null_section
    assert_html "", SECTION, :scope => {:test => nil}, :sections => true
  end

  def test_false_section
    assert_html "", SECTION, :scope => {:test => false}, :sections => true
  end

  def test_empty_string_section
    assert_html "Test", SECTION, :scope => {:test => ""}, :sections => true
  end

  def test_empty_array_section
    assert_html "", SECTION, :scope => {:test => []}, :sections => true
  end

  def test_empty_object_section
    assert_html "Test", SECTION, :scope => {:test => {}}, :sections => true
  end

  def test_undefined_inverted_section
    assert_html "Test", INVERTED_SECTION, :scope => {}, :sections => true
  end

  def test_null_inverted_section
    assert_html "Test", INVERTED_SECTION, :scope => {:test => nil}, :sections => true
  end

  def test_false_inverted_section
    assert_html "Test", INVERTED_SECTION, :scope => {:test => false}, :sections => true
  end

  def test_empty_string_inverted_section
    assert_html "", INVERTED_SECTION, :scope => {:test => ""}, :sections => true
  end

  def test_empty_array_inverted_section
    assert_html "Test", INVERTED_SECTION, :scope => {:test => []}, :sections => true
  end

  def test_empty_object_inverted_section
    assert_html "", INVERTED_SECTION, :scope => {:test => {}}, :sections => true
  end

  def test_doesnt_modify_context
    source = %q{
- constant_object
= constant_object_size
}
    assert_html '2', source, :sections => true
  end
end
