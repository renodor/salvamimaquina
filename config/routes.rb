# frozen_string_literal:true

Rails.application.routes.draw do
  # This line mounts Solidus's routes at the root of your application.
  # This means, any requests to URLs such as /products, will go to Spree::ProductsController.
  # If you would like to change where this engine is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Solidus relies on it being the default of "spree"
  mount Spree::Core::Engine, at: '/'

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
    end

    post '/checkout/three_d_secure_response', to: 'checkout#three_d_secure_response'

    namespace :api, defaults: { format: 'json' } do
      resources :districts, only: :index
    end

    delete '/frontend/orders/:order_id/line_items/:id', to: 'frontend/line_items#destroy', as: :frontend_line_item

    localized do
      resources :reparation_categories, only: [:index] do
        resources :reparation_requests, only: %i[new create]
      end
      get 'reparation_requests/thank_you', to: 'reparation_requests#thank_you'
    end

    localized do
      resources :trade_in_requests, only: %i[new create show], param: :token
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

    localized do
      get '/products/search_results', to: 'products#search_results'
    end
    get '/products/filter', to: 'products#filter'
    get '/products/product_variants_with_option_values', to: 'products#product_variants_with_option_values'
    get '/products/variant_with_options_hash', to: 'products#variant_with_options_hash'

    # Solidus Routes can't be localized using the localized block...
    # So we have to manually define the routes we want to translate here...
    get '/productos', to: 'products#index', as: 'products_es_mx'
    get '/productos/:id', to: 'products#show', as: 'product_es_mx'
    get '/carrito', to: 'orders#edit', as: 'cart_es_mx'
    get '/mi_cuenta', to: 'users#show', as: 'account_es_mx'
    get '/mi_cuenta/editar', to: 'users#edit', as: 'edit_account_es_mx'
    get '/pedidos/:id', to: 'orders#show', as: 'orders_es_mx'
  end

  namespace :repair_shopr_webhook do
    post 'product_updated', to: 'products#product_updated'
  end

  # Sidekiq Web UI, only for admins.
  require 'sidekiq/web'
  authenticate :spree_user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end
end
