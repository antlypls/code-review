require 'test_helper'
require 'groups'

class GroupsTest < MiniTest::Unit::TestCase
  def test_load_with_one_group
    Groups.load 'rails:ruby,javascript,cofeescript,sass,css'
    assert_equal 1, Groups.count
  end

  def test_load_parses_group
    Groups.load 'rails:ruby,javascript,cofeescript,sass,css'
    group = Groups.first
    assert_equal 'rails', group.name
    assert_equal %w(ruby javascript cofeescript sass css), group.languages
  end

  def test_load_parses_nil
    Groups.load(nil)
    assert_equal 0, Groups.count
  end

  def test_load_with_multiple_groups
    Groups.load 'rails:ruby,javascript;ios:objective-c'
    assert_equal 2, Groups.count

    group = Groups.entries.last
    assert_equal 'ios', group.name
    assert_equal %w(objective-c), group.languages
  end

  def test_find_by_name
    Groups.load 'rails:ruby,javascript;ios:objective-c'

    group = Groups.find_by_name('ios')
    assert_equal 'ios', group.name
  end

  def test_find_by_returns_nil
    Groups.load 'rails:ruby,javascript;ios:objective-c'

    group = Groups.find_by_name('some')
    assert_equal nil, group
  end
end
