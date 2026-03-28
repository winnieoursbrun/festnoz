source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.1"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Tailwind CSS is handled by Vite (see vite.config.ts)
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"
gem "web-push"

# Use Devise for authentication
gem "devise"
gem "devise-jwt"
gem "bcrypt", "~> 3.1.7"

# OmniAuth for OAuth authentication
gem "omniauth"
gem "omniauth-spotify"
gem "omniauth-rails_csrf_protection"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS)
gem "rack-cors"

# Geocoding services for location lookups
gem "geocoder"

# Full-text search for PostgreSQL
gem "pg_search"

# Use Vite for modern frontend asset bundling
gem "vite_rails"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mswin mswin64 mingw x64_mingw jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  # gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  # Test data factories
  gem "factory_bot_rails"

  # Fake data generation
  gem "faker"
end

group :test do
  # One-liner model/association tests
  gem "shoulda-matchers"

  # Context/describe/should DSL for Minitest
  gem "shoulda-context"

  # Bridges minitest/spec describe/it DSL into ActiveSupport::TestCase
  gem "minitest-spec-rails"

  # Mocking/stubbing for Minitest (replaces minitest/mock not in Minitest 6)
  gem "mocha"

  # HTTP request stubbing — prevent real external calls in tests
  gem "webmock"

  # Code coverage reporting
  gem "simplecov", require: false

  # Transactional test isolation
  gem "database_cleaner-active_record"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
end

gem "psych", "< 5.3" # Have a segfault with 5.3 and Rails 8.1

gem "stackprof"
gem "sentry-ruby"
gem "sentry-rails"
