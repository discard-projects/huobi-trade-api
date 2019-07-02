Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://127.0.0.1:6379/6' }
  config.error_handlers << Proc.new {|ex, ctx_hash| $slack_bug_notifier.ping "ex: #{ex}, ctx_hash: #{ctx_hash}" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://127.0.0.1:6379/6' }
end
