# frozen_string_literal: true

Sentry.init do |config|
  # config.enabled_environments = %w[production]
  config.dsn = 'https://24a55419e6214cdcbdc3dd58c2e637d9@o555754.ingest.sentry.io/5685830'
  config.breadcrumbs_logger = [:active_support_logger]

  config.async = lambda do |event, hint|
    SendEventToSentry.perform_later(event, hint)
  end
end
