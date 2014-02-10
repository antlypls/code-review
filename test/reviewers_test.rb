require 'test_helper'
require 'reviewers'

class ReviewersTest < MiniTest::Unit::TestCase
  def test_load
    Reviewers.load('me@work:me@home:me@road,you@work:you@home')

    assert_equal 2, Reviewers.count

    reviewer = Reviewers.first
    assert_equal 'me@work', reviewer.email
    assert_equal ['me@home', 'me@road'], reviewer.aliases
  end

  def test_load_with_groups
    Reviewers.load('me@work:me@home:me@road|rails,you@work:you@home|ios')

    assert_equal 2, Reviewers.count

    reviewer = Reviewers.entries.first
    assert_equal 'me@work', reviewer.email
    assert_equal 'rails', reviewer.group

    other_reviewer  = Reviewers.entries.last
    assert_equal 'you@work', other_reviewer.email
    assert_equal 'ios', other_reviewer.group
  end

  def test_for
    Reviewers.load('me@work:me@home:me@road,you@work:you@home')

    reviewers = Reviewers.for('me@home')
    assert_equal 1, reviewers.size
    assert_equal 'you@work', reviewers.first.email
  end

  def test_for_langs
    Reviewers.load('me@work:me@home:me@road|rails,you@work:you@home|ios')
    Groups.load('rails:ruby,javascript;ios:objective-c')

    reviewers = Reviewers.for('me@home', 'objective-c')
    assert_equal 1, reviewers.size
    assert_equal 'you@work', reviewers.first.email
  end

  def test_for_langs_array
    Reviewers.load('me@work:me@home:me@road|rails,you@work:you@home|ios')
    Groups.load('rails:ruby,javascript;ios:objective-c')

    reviewers = Reviewers.for('me@home', ['objective-c'])
    assert_equal 1, reviewers.size
    assert_equal 'you@work', reviewers.first.email
  end

  def test_for_multiple_langs
    Reviewers.load('me@work:me@home:me@road|rails,you@work:you@home|ios')
    Groups.load('rails:ruby,javascript;ios:objective-c')

    reviewers = Reviewers.for('me@home', ['objective-c', 'ruby'])
    assert_equal 1, reviewers.size
    assert_equal 'you@work', reviewers.first.email
  end
end
