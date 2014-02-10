require 'test_helper'

class GroupsApplicationTest < ApplicationTestCase
  def setup
    set :reviewers, 'tim@hyper.no|rails'
    set :groups, 'rails:ruby,javascript;native:cpp'
    enable :reload_settings
  end

  def teardown
    disable :reload_settings
  end

  def test_github
    Services::GitHub.expects(:diff)
    setup_github_mail_expectation

    post '/?service=github&langs=ruby', payload: github_json
  end

  def test_gitlab
    Services::GitLab.expects(:diff)
    setup_gitlab_mail_expectation

    post '/?service=gitlab&langs=javascript', gitlab_json
  end

  def test_github_multiple_langs
    Services::GitHub.expects(:diff)
    setup_github_mail_expectation

    post '/?service=github&langs=some,ruby', payload: github_json
  end

  def test_gitlab_multiple_langs
    Services::GitLab.expects(:diff)
    setup_gitlab_mail_expectation

    post '/?service=gitlab&langs=cpp,javascript', gitlab_json
  end

  def test_github_fail
    Services::GitLab.expects(:diff).never
    setup_no_mail_expectation
    post '/?service=github&langs=cpp', payload: github_json
  end

  def test_gitlab_fail
    Services::GitLab.expects(:diff).never
    setup_no_mail_expectation
    post '/?service=gitlab&langs=cpp', gitlab_json
  end
end
