# frozen_string_literal: true

# Code coverage — started before anything else
require "simplecov"
SimpleCov.start "rails" do
  add_filter "/test/"
  add_filter "/config/"
  add_filter "/db/"
  add_filter "/vendor/"
  add_group "Models",      "app/models"
  add_group "Controllers", "app/controllers"
  add_group "Services",    "app/services"
  add_group "Jobs",        "app/jobs"
end if ENV["COVERAGE"]

ENV["RAILS_ENV"] ||= "test"

require_relative "../config/environment"
require "rails/test_help"
require "webmock/minitest"
require "factory_bot_rails"
require "shoulda-context"
require "shoulda-matchers"
require "minitest-spec-rails"
require "mocha/minitest"

# Fix shoulda-context 2.0.0 incompatibility with Rails 8.1:
# shoulda-context's patch uses bare `executable` but Rails 8.1 uses `self.class.executable`
if defined?(Rails::TestUnitReporter)
  Rails::TestUnitReporter.class_eval do
    def format_rerun_snippet(result)
      location, line =
        if result.respond_to?(:source_location)
          result.source_location
        else
          result.method(result.name).source_location
        end
      "#{self.class.executable} #{relative_path_for(location)}:#{line}"
    end
  end
end

# Block all real HTTP connections in tests
WebMock.disable_net_connect!(allow_localhost: true)

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :minitest
    with.library :rails
  end
end

module ActiveSupport
  class TestCase
    include FactoryBot::Syntax::Methods
    self.use_transactional_tests = true

    # Generate a valid Devise JWT for a user
    def jwt_token_for(user)
      secret = Rails.application.credentials.devise_jwt_secret_key ||
               Rails.application.credentials.secret_key_base
      payload = {
        sub: user.id,
        scp: "user",
        aud: nil,
        iat: Time.now.to_i,
        exp: (Time.now + 1.week).to_i,
        jti: user.jti
      }
      JWT.encode(payload, secret, "HS256")
    end

    def auth_headers(user)
      { "Authorization" => "Bearer #{jwt_token_for(user)}", "Accept" => "application/json" }
    end

    def json_headers
      { "Accept" => "application/json" }
    end
  end
end
