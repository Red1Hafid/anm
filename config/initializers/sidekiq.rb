# require './lib/sidekiq/middleware/client/sidekiq_query_cache_middleware'
#
# Sidekiq.configure_client do |config|
#   config.client_middleware do |chain|
#     chain.add Sidekiq::Middleware::Client::SidekiqQueryCacheMiddleware
#   end
# end
# =======


require 'sidekiq'
require 'sidekiq-status'


Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::Status::ClientMiddleware
  end
  config.redis = { namespace: ENV['REDIS_NAMESPACE'], url: ENV['REDIS_URL'] }
end
Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Status::ServerMiddleware, expiration: 30.minutes # default
  end
  config.redis = { namespace: ENV['REDIS_NAMESPACE'], url: ENV['REDIS_URL'] }
end