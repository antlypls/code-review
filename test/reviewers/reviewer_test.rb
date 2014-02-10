require 'test_helper'

class Reviewers::ReviewerTest < MiniTest::Unit::TestCase
  include Reviewers

  def test_emails_with_array_aliases
    reviewer = Reviewer.new 'me@work', ['me@home']
    assert_equal ['me@work', 'me@home'], reviewer.emails
  end

  def test_emails_with_aliases_as_string
    reviewer = Reviewer.new 'me@work', 'me@home'
    assert_equal ['me@work', 'me@home'], reviewer.emails
  end

  def test_emails_with_empty_aliases
    reviewer = Reviewer.new 'me@work', []
    assert_equal ['me@work'], reviewer.emails
  end

  def test_emails_with_nil_aliases
    reviewer = Reviewer.new 'me@work'
    assert_equal ['me@work'], reviewer.emails
  end

  def test_parse_without_group
    reviewer = Reviewer.parse('me@work:me@home:me@road')

    assert_equal 'me@work', reviewer.email
    assert_equal ['me@home', 'me@road'], reviewer.aliases
    assert_equal nil, reviewer.group
  end

  def test_parse_with_group
    reviewer = Reviewer.parse('me@work:me@home:me@road|rails')

    assert_equal 'me@work', reviewer.email
    assert_equal ['me@home', 'me@road'], reviewer.aliases
    assert_equal 'rails', reviewer.group
  end

  def test_can_review_others
    reviewer = Reviewer.new('me@work', ['me@home'])
    assert reviewer.can_review?('you@work')
  end

  def test_cant_review_self
    reviewer = Reviewer.new('me@work', ['me@home'])
    assert !reviewer.can_review?('me@work')
    assert !reviewer.can_review?('me@home')
  end

  def test_can_review_langs
    Groups.load('rails:ruby,javascript;native:cpp')
    reviewer = Reviewer.new('me@work', ['me@home'], 'rails')
    assert reviewer.can_review?('you@work', 'ruby')
  end

  def test_cant_review_other_langs
    Groups.load('rails:ruby,javascript;native:cpp')
    reviewer = Reviewer.new('me@work', ['me@home'], 'rails')
    assert !reviewer.can_review?('you@work', 'cpp')
  end

  def test_cant_review_self_with_known_lang
    Groups.load('rails:ruby,javascript;native:cpp')
    reviewer = Reviewer.new('me@work', ['me@home'], 'rails')
    assert !reviewer.can_review?('me@work', 'ruby')
  end

  def test_understands_any_language
    Groups.load('rails:ruby,javascript;native:cpp')
    reviewer = Reviewer.new('me@work', nil, 'rails')
    assert reviewer.understands_any_language?(%w{ruby cpp})
  end

  def test_understands_any_language_none
    Groups.load('rails:ruby,javascript;native:cpp')
    reviewer = Reviewer.new('me@work', nil, 'rails')
    assert !reviewer.understands_any_language?(%w{c cpp})
  end

  def test_understands_language
    Groups.load('rails:ruby,javascript;native:cpp')
    reviewer = Reviewer.new('me@work', nil, 'rails')
    assert reviewer.understands_language?('ruby')
    assert !reviewer.understands_language?('cpp')
  end

  def test_understands_nil
    reviewer = Reviewer.new('me@work', nil, 'rails')
    assert reviewer.understands_language?(nil)
  end

  def test_understands_empty
    reviewer = Reviewer.new('me@work', nil, 'rails')
    assert reviewer.understands_language?('')
  end

  def test_understands_everything_with_nil_group
    reviewer = Reviewer.new('me@work', nil, nil)
    assert reviewer.understands_language?('some')
  end

  def test_understands_everything_with_empty_group
    reviewer = Reviewer.new('me@work', nil, '')
    assert reviewer.understands_language?('other')
  end
end
