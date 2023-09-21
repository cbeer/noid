require 'bundler/setup'
require 'byebug' unless ENV['CI']

if ENV['COVERAGE'] && RUBY_VERSION =~ /^1.9/
  require 'simplecov'
  SimpleCov.start
end

require 'noid'

RSpec.configure do |_config|
end
