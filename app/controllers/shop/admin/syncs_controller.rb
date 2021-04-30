class Shop::Admin::SyncsController < ApplicationController
  before_action :set_sync_logs, except: :index
  after_action :save_sync_logs, except: :index

  def index
    redirect_to '/shop/admin/login' and return unless current_spree_user&.admin?

    @sync_logs = RepairShoprProductsSyncLog.all.order(created_at: :desc)
  end

  def sync_everything
    RepairShoprApi::V1::SyncEverything.call(sync_logs: @sync_logs)
    redirect_to shop_admin_sync_path
  end

  def sync_product_categories
    RepairShoprApi::V1::SyncProductCategories.call(sync_logs: @sync_logs)
    redirect_to shop_admin_sync_path
  end

  def sync_products
    RepairShoprApi::V1::SyncProducts.call(sync_logs: @sync_logs)
    redirect_to shop_admin_sync_path
  end

  private

  def set_sync_logs
    @sync_logs = RepairShoprProductsSyncLog.new
  end

  def save_sync_logs
    @sync_logs.save!
    Sentry.capture_message(self.class.name, extra: { sync_logs_errors: @sync_logs.sync_errors }) if @sync_logs.sync_errors.any?
  end
end
