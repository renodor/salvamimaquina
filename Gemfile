source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.6'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1', '>= 6.1.3'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 4.1'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 4.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

# Ecommerce Framework
gem 'solidus', github: 'solidusio/solidus', branch: 'v2.11'
gem 'solidus_sale_prices', github: 'solidusio-contrib/solidus_sale_prices'
gem 'solidus_related_products', github: 'solidusio-contrib/solidus_related_products'

# HTTP client
gem 'faraday'

# Optimized JSON parser
gem 'oj'

# Exception management
gem 'sentry-rails'
gem 'sentry-ruby'

# Image storage
gem 'cloudinary', '~> 1.19'

# I18n
gem 'solidus_i18n', '~> 2.0'
gem 'rails-i18n'
gem 'kaminari-i18n', '~> 0.5.0'

# Pass env variables to JS
gem 'gon'

gem 'sidekiq'
gem 'sidekiq-failures', '~> 1.0'

gem 'jwt'

# Transactional emails
gem 'postmark-rails'

gem 'simple_form'

# Honeypot to prevent spam on the contact form
gem 'invisible_captcha'

gem 'route_translator'

gem 'solidus_auth_devise', '2.5.4'

# Eliminate render-blocking CSS in above-the-fold content
gem 'rails_critical_css_server'

group :development, :test do
  # For debugging
  gem 'pry-byebug'
  gem 'pry-rails'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # To simulate sending emails
  gem 'letter_opener'

  # Launch cross-platform applications
  # (used to open a new browser tab from controller or service class)
  gem 'launchy'

  gem 'rubocop', require: false

  # Find N+1 queries
  gem 'bullet'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
