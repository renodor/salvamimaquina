# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = 'https://24a55419e6214cdcbdc3dd58c2e637d9@o555754.ingest.sentry.io/5685830'
  config.breadcrumbs_logger = [:active_support_logger]

  # Set tracesSampleRate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production
  config.traces_sample_rate = 0.5
  # or
  config.traces_sampler = lambda do |context|
    true
  end
end