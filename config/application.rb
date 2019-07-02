require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module HuobiAutoTrade
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Initialize configuration defaults for originally generated Rails version.
    config.before_configuration do
      # 這裡會自動依據你的 Rails.env 來讀取，不需要自己取出
      $env = config_for(:application).freeze if File.exists?(Rails.root.join('config', 'application.yml'))
      # $redis_config = config_for(:redis).freeze if File.exists?(Rails.root.join('config', 'redis.yml'))
    end

    config.time_zone = 'Beijing'
    # 配置该项，数据库存储和项目时区一致，默认数据库存储utc时间
    config.active_record.default_timezone = :local

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # Rails 6 这里必须设置项目的hosts，Why?
    Rails.application.config.hosts += $env[:sys_hosts] || []

    config.eager_load_paths << Rails.root.join('lib')
    config.eager_load_paths << Rails.root.join('app/mailers')

    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore
  end
end
