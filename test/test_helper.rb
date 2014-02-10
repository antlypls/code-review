$: << "lib"

require 'reviewers/reviewer'
require 'groups/group'

require 'simplecov'
require 'coveralls'

SimpleCov.command_name 'Unit Tests'

Coveralls.wear!

ENV['RACK_ENV']   = 'test'
ENV['ODDS']       = '1:1'
ENV['REVIEWERS']  = 'johannes@hyper.no:jgorset@gmail.com,tim@hyper.no'
ENV['SENDER']     = 'Hyper <no-reply@hyper.no>'

require 'application'
require 'odds'
require 'minitest/unit'
require 'minitest/autorun'
require 'rack/test'
require 'mocha/mini_test'

require 'support/application_test_case'

def fixture(file)
  File.read("test/fixtures/#{file}")
end
