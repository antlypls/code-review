class ApplicationTestCase < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup_github_mail_expectation
    Pony.
      expects(:mail).
      with(has_entries(
        to: 'tim@hyper.no',
        reply_to: 'johannes@hyper.no',
        cc: 'johannes@hyper.no',
        subject: 'Code review for testing/master@c441029',
        from: 'Hyper <no-reply@hyper.no>'
      )).once
  end

  def setup_gitlab_mail_expectation
    Pony.
      expects(:mail).
      with(has_entries(
        to: 'tim@hyper.no',
        reply_to: 'johannes@hyper.no',
        cc: 'johannes@hyper.no',
        subject: 'Code review for Diaspora/master@b6568db',
        from: 'Hyper <no-reply@hyper.no>'
      )).once
  end

  def setup_no_mail_expectation
    Pony.expects(:mail).never
  end

  def github_json
    fixture('github.json')
  end

  def gitlab_json
    fixture('gitlab.json')
  end

  def review_gitlab_json
    gitlab_json.sub(
      'Update Catalan translation to e38cb41.',
      'Test. Please review.'
    )
  end
end
