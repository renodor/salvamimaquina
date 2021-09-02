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
      get '/sync', to: 'syncs#index'
      get '/sync/everything', to: 'syncs#sync_everything'
      get '/sync/product_categories', to: 'syncs#sync_product_categories'
      get '/sync/products', to: 'syncs#sync_products'
      post '/sync/product', to: 'syncs#sync_product'
    end

    post '/checkout/three_d_secure_response', to: 'checkout#three_d_secure_response'
    get '/bac/bac_checkout', to: 'bac#bac_checkout'

    namespace :api, defaults: { format: 'json' } do
      resources :districts, only: :index
    end

    delete '/frontend/orders/:order_id/line_items/:id', to: 'frontend/line_items#destroy', as: :frontend_line_item
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
