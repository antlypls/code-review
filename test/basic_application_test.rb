require 'test_helper'

class BasicApplicationTest < ApplicationTestCase
  def test_github
    Services::GitHub.expects(:diff)
    setup_github_mail_expectation

    post '/?service=github', payload: github_json
  end

  def test_gitlab
    Services::GitLab.expects(:diff)
    setup_gitlab_mail_expectation

    post '/?service=gitlab', gitlab_json
  end

  def test_guaranteed_review
    commit = { 'message' => 'Test. Please review this.' }
    assert guaranteed_review?(commit), 'Should guarantee a review.'
  end

  def test_gitlab_guaranteed_review
    Services::GitLab.expects(:diff)
    setup_gitlab_mail_expectation

    # Configure odds to never deliver code reviews
    set :odds, '0:0'
    post '/?service=gitlab', review_gitlab_json
    # Configure odds to deliver code reviews again
    set :odds, ENV['ODDS']
  end
end
