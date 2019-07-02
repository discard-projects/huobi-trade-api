source 'https://gems.ruby-china.com'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.0.rc1'
# Use mysql as the database for Active Record
gem 'mysql2', '>= 0.4.4'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

# Auth
gem 'devise'
gem 'devise_token_auth'

# job
gem 'sidekiq'

# AASM is a continuation of the acts-as-state-machine rails plugin, built for plain Ruby objects
gem 'aasm'
# tree
gem 'ancestry'
# position
gem 'acts_as_list'
# logs
gem 'footprintable'
# Self Gems
# https://github.com/rails-gems/timequery
gem 'timequery'
# https://github.com/rails-gems/split_routes
gem 'split_routes'
# Base Resource include: reform, reform-rails, kaminari, ransack
gem 'ransack'
gem 'kaminari'
gem 'reform'
gem 'reform-rails'
gem 'base_resource', github: 'rails-gems/base-resource'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'
# Http
gem 'httparty'
# split_routes
gem 'split_routes'
# 定时任务
gem 'whenever', require: false


# Slack api 封装
gem 'slack-notifier'
# 异常监控
gem 'exception_notification'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end


# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
