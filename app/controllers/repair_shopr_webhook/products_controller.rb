class RepairShoprWebhook::ProductsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def product_updated
    # Only accept requests coming from the correct RS sender
    return unless params['link'].include?("https://#{Rails.application.credentials.repair_shopr_subdomain}.repairshopr.com/products/")

    # Only sync products belonging to the "ecom" category
    return unless params['attributes']['product_categories'].includes?(RepairShoprApi::V1::Base::RS_ROOT_CATEGORY_NAME)
    # Only sync enabled products
    return if params['attributes']['disabled']

    # Don't sync the params['attributes'] directly as anyone could create such request
    # Instead just get the product id and fetch attributes of this product directly on RepairShopr
    RepairShoprApi::V1::SyncProduct.call(sync_logs: RepairShoprProductsSyncLog.new, repair_shopr_id: params['attributes']['id'])
    head :ok
  end
end
