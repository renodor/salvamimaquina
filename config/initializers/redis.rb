# frozen_string_literal: true

url = ENV['REDISCLOUD_URL']

if url
  Sidekiq.configure_server do |config|
    config.redis = { url: url, ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }, network_timeout: 5 }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: url, ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }, network_timeout: 5 }
  end

end
