class RepairShoprWebhook::ProductsController < ApplicationController
  skip_before_action :verify_authenticity_token
  # before_action :authenticate

  def product_updated
    return unless params['link'].include?('https://coolshop.repairshopr.com/products/')

    RepairShoprApi::V1::Product.update_product(params['attributes']['id'])
    head :ok
  end

  private

  def authenticate
    authenticate_or_request_with_http_token do |token, _options|
      # Compare the tokens in a time-constant manner, to mitigate timing attacks.
      ActiveSupport::SecurityUtils.secure_compare(token, Rails.application.credentials.repair_shopr_api_key)
    end
  end
end