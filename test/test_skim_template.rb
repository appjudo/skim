require 'helper'

class TestSlimTemplate < TestSkim
  def test_registered_extension
    assert_equal Skim::Template, Tilt['test.skim']
  end
end
