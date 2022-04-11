# frozen_string_literal:true

class Spree::Admin::SyncRepairShoprController < Spree::Admin::BaseController
  def index
    @sync_logs = RepairShoprProductsSyncLog.order(created_at: :desc).page(params[:page]) # TODO: paginate instead of limiting to 100
  end

  def new
    SyncRepairShoprJob.perform_later(RepairShoprProductsSyncLog.create!)
    redirect_to admin_sync_repair_shopr_index_path
  end
end
