# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
# defaults format: :json do
#   resources :anyname
# end
# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
# defaults format: :json do
#   resources :anyname
# end
defaults format: :json do
  constraints subdomain: /api/ do
    mount_devise_token_auth_for 'User', at: 'auth'
    scope module: 'api' do
      namespace :v1 do

        resources :user, only: [:create, :update]

        resources :balances, model_name: 'Balance' do
          resources :footprints, only: [:index]
        end
        resources :balance_intervals, only: [:index, :destroy]
        # resources :balance_plans, only: [:index, :destroy]
        # resources :balance_smarts, only: [:index, :destroy]
        #
        # resources :order_plans, only: [:index, :show], model_name: 'OrderPlan' do
        #   resources :footprints, only: [:index]
        # end
        #
        # resources :order_smarts, only: [:index, :show], model_name: 'OrderSmart' do
        #   resources :footprints, only: [:index]
        # end
        #
        resources :trade_symbols, only: [:index] do
          put :toggle_switch, on: :member
        end

        resources :orders, model_name: 'Order' do
          put :change_status, on: :member
          resources :footprints, only: [:index]
        end
      end
    end
  end
end