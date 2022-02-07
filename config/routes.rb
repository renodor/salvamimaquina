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
      resources :syncs, only: %i[index new]
      resources :reparation_categories, except: :show
      resources :reparation_requests, only: %i[index show]
      resources :banners, except: :show
      resources :sliders do
        resources :slides
      end
    end

    post '/checkout/three_d_secure_response', to: 'checkout#three_d_secure_response'
    get '/bac/bac_checkout', to: 'bac#bac_checkout'

    namespace :api, defaults: { format: 'json' } do
      resources :districts, only: :index
    end

    delete '/frontend/orders/:order_id/line_items/:id', to: 'frontend/line_items#destroy', as: :frontend_line_item

    resources :reparation_categories, only: [:index] do
      resources :reparation_requests, only: %i[new create]
    end

    resources :trade_in, only: %i[index] do
      member do
        get :variant_infos
      end
    end

    get '/account/edit_user_address', to: 'users#edit_user_address'
    get '/account/new_user_address', to: 'users#new_user_address'
    put '/account/update_user_address', to: 'users#update_user_address'

    get '/t/filter_products', to: 'taxons#filter_products'
    get '/products/product_variants_with_option_values', to: 'products#product_variants_with_option_values'
    get '/products/variant_with_options_hash', to: 'products#variant_with_options_hash'
    get 'reparation_requests/thank_you', to: 'reparation_requests#thank_you'

    get 'corporate_clients', to: 'home#corporate_clients'
    post 'create_corporate_client_message', to: 'home#create_corporate_client_message'
    get 'contact', to: 'home#contact'
    get 'about', to: 'home#about'
    post 'create_user_message', to: 'home#create_user_message'
    get 'shipping_informations', to: 'home#shipping_informations'
    get 'payment_methods', to: 'home#payment_methods'
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
