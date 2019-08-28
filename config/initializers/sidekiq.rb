Sidekiq::Logging.logger.level = Logger::WARN
Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://127.0.0.1:6379/6' }
  config.error_handlers << Proc.new do |ex, ctx_hash|
    # $slack_bug_notifier.ping "ex: #{ex}, ctx_hash: #{ctx_hash}"
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://127.0.0.1:6379/6' }
end
