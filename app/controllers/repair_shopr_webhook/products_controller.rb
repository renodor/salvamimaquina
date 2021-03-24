class RepairShoprWebhook::ProductsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def product_updated
    return unless params['link'].include?("https://#{Rails.application.credentials.repair_shopr_subdomain_test}.repairshopr.com/products/")

    RepairShoprApi::V1::SyncProduct.call(id: params['attributes']['id'])
    head :ok
  end
end
