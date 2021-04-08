Rails.application.routes.draw do
  # This line mounts Solidus's routes at the root of your application.
  # This means, any requests to URLs such as /products, will go to Spree::ProductsController.
  # If you would like to change where this engine is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Solidus relies on it being the default of "spree"
  mount Spree::Core::Engine, at: '/shop'
  namespace :shop do
    get '/admin/sync', to: 'syncs#index', as: :sync
    get '/admin/sync/everything', to: 'syncs#sync_everything', as: :sync_everything
    get '/admin/sync/products', to: 'syncs#sync_products', as: :sync_products
  end


  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :repair_shopr_webhook do
    post 'product_updated', to: 'products#product_updated'
  end
end
