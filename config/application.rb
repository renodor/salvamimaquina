# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Salvamimaquina
  class Application < Rails::Application
    # Load application's model / class decorators
    initializer 'spree.decorators' do |app| # rubocop:disable Lint/UnusedBlockArgument
      config.to_prepare do
        Dir.glob(Rails.root.join('app/**/*_decorator*.rb')) do |path|
          require_dependency(path)
        end
      end
    end
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    config.active_job.queue_adapter = :sidekiq

    # Following this guide to load custom permission set files in our Spree application:
    # https://guides.solidus.io/developers/customizations/customizing-permissions.html#customizing-permissions
    config.before_initialize do
      Dir.glob(File.join(File.dirname(__FILE__), '../lib/spree/permission_sets/*.rb')) do |c|
        require_dependency(c)
      end
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
