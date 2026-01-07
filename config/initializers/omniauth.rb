# frozen_string_literal: true

# Configure OmniAuth
# Note: Providers are configured in config/initializers/devise.rb for Devise integration
# This file is only for OmniAuth-specific settings

# Allow GET requests for OAuth (in addition to POST)
# This is needed because omniauth-rails_csrf_protection requires POST by default
# but we want to support GET requests for backwards compatibility and easier testing
OmniAuth.config.allowed_request_methods = [:get, :post]

# Handle OmniAuth errors
OmniAuth.config.on_failure = proc { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}
