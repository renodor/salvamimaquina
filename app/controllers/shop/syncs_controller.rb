class Shop::SyncsController < ApplicationController
  def index
    @show_sync_logs = RepairShoprProductsSyncLog.all.order(created_at: :desc)
  end

  def sync_everything
    RepairShoprApi::V1::SyncProducts.call
    redirect_to shop_sync_path
  end

  def sync_products
    sync_logs = RepairShoprProductsSyncLog.new
    products = Spree::Products.all
    RepairShoprApi::V1::SyncProduct.call
    redirect_to shop_sync_path
  end
end
