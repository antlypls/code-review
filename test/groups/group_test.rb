require 'test_helper'

class Groups::GroupTest < MiniTest::Unit::TestCase
  include Groups

  def test_parse
    group = Group.parse('rails:ruby,javascript')
    assert_equal 'rails', group.name
    assert_equal %w(ruby javascript), group.languages
  end

  def test_language
    group = Group.parse('rails:ruby,javascript')
    assert group.language?('ruby')
    assert !group.language?('cpp')
  end
end
