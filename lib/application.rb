require 'sinatra'
require 'json'
require 'pony'
require 'httparty'
require 'pygments'
require 'gravatar'
require 'odds'
require 'services'
require 'reviewers'
require 'groups'
require 'premailer'
require 'helpers'

configure do
  set :odds, ENV['ODDS']
  set :gitlab_private_token, ENV['GITLAB_PRIVATE_TOKEN']
  set :reviewers, ENV['REVIEWERS']
  set :groups, ENV['GROUPS']
  set :sender, ENV['SENDER']
  set :guaranteed_review, ENV['GUARANTEED_REVIEW'] || 'please review'
  set :reload_settings, false
end

Pony.options = {
  via: :smtp,
  via_options: {
    address: ENV['SMTP_HOST'],
    port: ENV['SMTP_PORT'],
    domain: ENV['SMTP_DOMAIN'],
    user_name: ENV['SMTP_USERNAME'],
    password: ENV['SMTP_PASSWORD'],
    authentication: :plain,
    enable_starttls_auto: true
  }
}

Services::GitLab.configure do |config|
  config.private_token = settings.gitlab_private_token
end

Groups.load(settings.groups)
Reviewers.load(settings.reviewers)

before '/' do
  if settings.reload_settings
    Groups.load(settings.groups)
    Reviewers.load(settings.reviewers)
  end

  halt(412) unless valid_branch?
end

post '/' do
  request_data['commits'].each do |commit|
    send_commit_for_review(commit) if send_commit_for_review?(commit)
  end
  ''
end

def service
  @service ||= if params.include?('service')
    Services.lookup(params[:service])
  else
    warn "Queries that don't specify a service are deprecated."
    Services::GitLab
  end
end

def request_data
  @request_data ||= service.parse_request(request)
end

def repository
  request_data['repository']['name']
end

def branch
  request_data['ref'].sub('refs/heads/', '')
end

def languages
  @languages = (params[:langs] || '').split(',')
end

def send_commit_for_review(commit)
  reviewers = Reviewers.for(commit['author']['email'], languages)

  if reviewer = reviewers.sample
    mail_body = generate_mail_body(commit)
    send_mail(mail_body, reviewer, commit)
  end
end

def generate_mail_body(commit)
  diff     = service.diff(commit['url'])
  gravatar = Gravatar.new(commit['author']['email'])

  html = erb :mail, locals: {
    gravatar: gravatar,
    commit: commit,
    diff: diff
  }

  Premailer.new(html, with_html_string: true, input_encoding: 'UTF-8')
end

def send_mail(mail, reviewer, commit)
  Pony.mail(
    to: reviewer.email,
    from: settings.sender,
    reply_to: commit['author']['email'],
    cc: commit['author']['email'],
    subject: "Code review for #{repository}/#{branch}@#{commit['id'][0,7]}",
    headers: { 'Content-Type' => 'text/html' },
    body: mail.to_inline_css
  )
end

# Check if the commit should be reviewed
# based on random draw
def send_commit_for_review?(commit)
  Odds.roll(settings.odds) || guaranteed_review?(commit)
end

# Check if the commit should guarantee a review.
# commit - A hash describing a commit.
# Returns a boolean describing if a commit should be reviewed or not.
def guaranteed_review?(commit)
  commit['message'].downcase.include?(settings.guaranteed_review.downcase)
end

def valid_branch?
  if params[:only_branches].present?
    return false unless params[:only_branches].split(',').include?(branch)
  elsif params[:except_branches].present?
    return false if params[:except_branches].split(',').include?(branch)
  end
  true
end
