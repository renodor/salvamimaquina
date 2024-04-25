# frozen_string_literal: true

REDIS_POOL = ConnectionPool.new do
  Redis.new(
    url: ENV['REDISCLOUD_URL'],
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
  )
end
