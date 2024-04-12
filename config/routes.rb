# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#index'

  devise_for(:user, {
    class_name: 'Spree::User',
    singular: :spree_user,
    controllers: {
      sessions: 'user_sessions',
      registrations: 'user_registrations',
      passwords: 'user_passwords',
      confirmations: 'user_confirmations'
    },
    skip: [:unlocks, :omniauth_callbacks],
    path_names: { sign_out: 'logout' }
  })

  resources :users, only: [:edit, :update]

  devise_scope :spree_user do
    get '/login', to: 'user_sessions#new', as: :login
    post '/login', to: 'user_sessions#create', as: :create_new_session
    match '/logout', to: 'user_sessions#destroy', as: :logout, via: Devise.sign_out_via
    get '/signup', to: 'user_registrations#new', as: :signup
    post '/signup', to: 'user_registrations#create', as: :registration
    get '/password/recover', to: 'user_passwords#new', as: :recover_password
    post '/password/recover', to: 'user_passwords#create', as: :reset_password
    get '/password/change', to: 'user_passwords#edit', as: :edit_password
    put '/password/change', to: 'user_passwords#update', as: :update_password
    get '/confirm', to: 'user_confirmations#show', as: :confirmation if Spree::Auth::Config[:confirmable]
  end

  resource :account, controller: 'users'

  localized do
    resources :products, only: %i[index show] do
      member do
        post :select_variant
      end

      collection do
        get :filter
        get :search_results
      end
    end
  end

  resources :autocomplete_results, only: :index

  resources :cart_line_items, only: %i[create destroy]

  get '/locale/set', to: 'locale#set'
  post '/locale/set', to: 'locale#set', as: :select_locale

  resource :checkout_session, only: :new
  resource :checkout_guest_session, only: :create

  # non-restful checkout stuff
  patch '/checkout/update/:state', to: 'checkouts#update', as: :update_checkout
  get '/checkout/:state', to: 'checkouts#edit', as: :checkout_state
  get '/checkout', to: 'checkouts#edit', as: :checkout

  get '/orders/:id/token/:token' => 'orders#show', as: :token_order

  resources :orders, only: :show do
    resources :coupon_codes, only: :create
  end

  resource :cart, only: [:show, :update] do
    put 'empty'
  end

  # route globbing for pretty nested taxon and product paths
  get '/t/*id', to: 'taxons#show', as: :nested_taxons

  get '/unauthorized', to: 'home#unauthorized', as: :unauthorized
  get '/cart_link', to: 'store#cart_link', as: :cart_link

  # This line mounts Solidus's routes at the root of your application.
  # This means, any requests to URLs such as /products, will go to Spree::ProductsController.
  # If you would like to change where this engine is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Solidus relies on it being the default of "spree"
  mount Spree::Core::Engine, at: '/'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  delete '/orders/:order_id/coupon_codes/:id', to: 'coupon_codes#remove', as: :remove_order_coupon_codes

  localized do
    resources :reparation_categories, only: [:index] do
      resources :reparation_requests, only: %i[new create]
    end
    get 'reparation_requests/thank_you', to: 'reparation_requests#thank_you'
  end

  localized do
    resources :trade_in_requests, only: %i[new create], param: :token
    get 'trade_in_requests/confirmed/:token', to: 'trade_in_requests#show', param: :token, as: :trade_in_request
  end
  get 'trade_in_requests/variant_infos/:variant_id', to: 'trade_in_requests#variant_infos'

  localized do
    get '/account/edit_user_address', to: 'users#edit_user_address'
    get '/account/new_user_address', to: 'users#new_user_address'
  end
  put '/account/update_user_address', to: 'users#update_user_address'

  localized do
    get 'corporate_clients', to: 'home#corporate_clients'
  end
  post 'create_corporate_client_message', to: 'home#create_corporate_client_message'

  localized do
    get 'contact', to: 'home#contact'
    get 'about', to: 'home#about'
    get 'shipping_informations', to: 'home#shipping_informations'
    get 'payment_methods', to: 'home#payment_methods'
    get 'identify_your_model', to: 'home#identify_your_model'
  end
  post 'create_user_message', to: 'home#create_user_message'

  get '/fake_api_call/show_request', to: 'fake_api_calls#show_request'

  # Solidus Routes can't be localized using the localized block...
  # So we have to manually define the routes we want to translate here...
  get '/carrito', to: 'carts#show', as: 'cart_es_mx'
  get '/mi_cuenta', to: 'users#show', as: 'account_es_mx'
  get '/mi_cuenta/editar', to: 'users#edit', as: 'edit_account_es_mx'
  get '/pedidos/:id', to: 'orders#show', as: 'orders_es_mx'

  namespace :repair_shopr_webhook do
    post 'product_updated', to: 'products#product_updated'
  end

  post '/checkout/three_d_secure_response', to: 'checkouts#three_d_secure_response'

  Spree::Core::Engine.routes.draw do
    namespace :admin do
      resources :sync_repair_shopr, only: %i[index new]
      resources :reparation_categories, except: :show
      resources :reparation_requests, only: %i[index show]
      resources :banners, except: :show
      resources :sliders do
        resources :slides
      end
      resources :trade_in_models, only: %i[index] do
        collection do
          get :sync
        end
      end
      resources :trade_in_requests, only: %i[index]

      get '/documentation', to: 'documentation#index'
    end
  end

  # Sidekiq Web UI, only for admins.
  require 'sidekiq/web'
  authenticate :spree_user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end
end
