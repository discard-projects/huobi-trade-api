require 'sidekiq/web'
Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  constraints lambda {|request| request.cookies['secret'] == $env['sidekiq_secret'] } do
    mount Sidekiq::Web => '/sidekiq'
  end
end
