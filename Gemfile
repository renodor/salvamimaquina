source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 7.0.6'

gem 'solidus', '4.2.3'
gem 'solidus_sale_prices', git: 'https://github.com/renodor/solidus_sale_prices.git', branch: 'master'
gem 'solidus_related_products', git: 'https://github.com/renodor/solidus_related_products.git', branch: 'master'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 5.0'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem 'kredis'

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem 'bcrypt', '~> 3.1.7'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Sass to process CSS
gem 'sassc-rails'

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem 'image_processing', '~> 1.2'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[ mri mingw x64_mingw ]
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem 'rack-mini-profiler'

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem 'spring'

  # To simulate sending emails
  gem 'letter_opener'

  # Launch cross-platform applications
  # (used to open a new browser tab from controller or service class)
  gem 'launchy'

  # Find N+1 queries
  gem 'bullet'

  gem 'brakeman'
end

gem 'solidus_auth_devise', '~> 2.5'
gem 'responders'
gem 'canonical-rails'
gem 'solidus_support'
gem 'truncate_html'
gem 'view_component', '~> 3.0'

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'capybara-screenshot', '~> 1.0'
  gem 'database_cleaner-active_record'

  # Stubbing http requests
  gem "webmock"
end

group :development, :test do
  gem 'rspec-rails'
  gem 'rails-controller-testing', '~> 1.0.5'
  gem 'rspec-activemodel-mocks', '~> 1.1.0'
  gem 'factory_bot', '>= 4.8'
  gem 'factory_bot_rails'
  gem 'ffaker', '~> 2.13'
  gem 'rubocop', '~> 1.0'
  gem 'rubocop-performance', '~> 1.5'
  gem 'rubocop-rails', '~> 2.3'
  gem 'rubocop-rspec', '~> 2.0'

  # For debugging
  gem 'pry-byebug'
  gem 'pry-rails'
end

# HTTP client
gem 'faraday'

# Optimized JSON parser
gem 'oj'

# Exception management
gem 'sentry-rails'
gem 'sentry-ruby'

# Image storage
gem 'cloudinary', '~> 1.28'

gem 'sidekiq', '< 7.0'
gem 'sidekiq-failures', '~> 1.0'

gem 'jwt'

# Transactional emails
gem 'postmark-rails'

gem 'simple_form'

# Honeypot to prevent spam on the contact form
gem 'invisible_captcha'

# Eliminate render-blocking CSS in above-the-fold content
gem 'rails_critical_css_server'

# I18n
gem 'solidus_i18n', '~> 2.0'
gem 'rails-i18n'
gem 'kaminari-i18n', '~> 0.5.0'

# Route translator
gem 'route_translator'

# Bootstrap
gem 'bootstrap', '~> 5.3.2'
