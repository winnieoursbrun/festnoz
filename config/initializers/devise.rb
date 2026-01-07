# frozen_string_literal: true

Devise.setup do |config|
  # The secret key used by Devise. Devise uses this key to generate
  # random tokens. Changing this key will render invalid all existing
  # confirmation, reset password and unlock tokens in the database.
  config.secret_key = Rails.application.credentials.secret_key_base

  # ==> Mailer Configuration
  config.mailer_sender = "noreply@festnoz.com"

  # ==> ORM configuration
  require "devise/orm/active_record"

  # ==> Configuration for :database_authenticatable
  config.stretches = Rails.env.test? ? 1 : 12

  # ==> Configuration for :validatable
  config.password_length = 6..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  # ==> Configuration for :timeoutable
  # config.timeout_in = 30.minutes

  # ==> Configuration for :lockable
  # config.lock_strategy = :failed_attempts
  # config.unlock_keys = [:email]
  # config.unlock_strategy = :both
  # config.maximum_attempts = 20
  # config.unlock_in = 1.hour
  # config.last_attempt_warning = true

  # ==> Configuration for :recoverable
  config.reset_password_within = 6.hours

  # ==> Configuration for JWT
  config.jwt do |jwt|
    jwt.secret = Rails.application.credentials.devise_jwt_secret_key || Rails.application.credentials.secret_key_base
    jwt.dispatch_requests = [
      [ "POST", %r{^/api/auth/login$} ],
      [ "POST", %r{^/api/auth/signup$} ]
    ]
    jwt.revocation_requests = [
      [ "DELETE", %r{^/api/auth/logout$} ]
    ]
    jwt.expiration_time = 1.week.to_i
  end

  # ==> Scopes configuration
  config.scoped_views = true

  # ==> Navigation configuration
  config.sign_out_via = :delete

  # ==> Warden configuration
  config.warden do |manager|
    manager.failure_app = proc { |_env|
      [ "401", { "Content-Type" => "application/json" }, [ { error: "Unauthorized" }.to_json ] ]
    }
  end

  # ==> OmniAuth configuration
  # Configure OmniAuth providers
  config.omniauth :spotify,
                  Rails.application.credentials.spotify_client_id,
                  Rails.application.credentials.spotify_client_secret,
                  scope: "user-read-email user-read-private user-library-read user-follow-read playlist-read-private user-top-read user-read-recently-played"
end
