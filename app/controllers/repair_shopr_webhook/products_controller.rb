class RepairShoprWebhook::ProductsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def product_updated
    logger.info("PARAMS ARE HERE: #{params}")
  end
end
