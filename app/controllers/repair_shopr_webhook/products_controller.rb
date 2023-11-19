# frozen_string_literal:true

class RepairShoprWebhook::ProductsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def product_updated
    repair_shopr_subdomain = Rails.env.production? ? Rails.application.credentials.repair_shopr_subdomain : Rails.application.credentials.repair_shopr_subdomain_test

    # Only accept requests coming from the correct RS sender
    return unless params['link']&.include?("https://#{repair_shopr_subdomain}.repairshopr.com/products/")

    # Only sync products enabled and belonging to the "ecom" category
    # If it is not the case but the variant exists, we need to destroy it
    if params['attributes']['product_category']&.include?(RepairShoprApi::V1::Base::RS_ROOT_CATEGORY_NAME) && !params['attributes']['disabled']
      # Don't sync the params['attributes'] directly as anyone could create such request
      # Instead just get the product id and fetch attributes of this product directly on RepairShopr
      product = RepairShoprApi::V1::Base.get_product(params['attributes']['id'])
      sync_logs = RepairShoprProductsSyncLog.create!

      RepairShoprApi::V1::SyncProduct.call(sync_logs: sync_logs, attributes: product)

      sync_logs.update!(status: sync_logs.sync_errors.any? ? 'error' : 'complete')
    elsif (variant = Spree::Variant.find_by(repair_shopr_id: params['attributes']['id']))
      variant.destroy_and_destroy_product_if_no_other_variants!
    end

    head :ok
  end
end
