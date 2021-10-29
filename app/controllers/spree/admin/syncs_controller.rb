# frozen_string_literal:true

class Spree::Admin::SyncsController < Spree::Admin::BaseController
  def index
    redirect_to '/admin/login' and return unless current_spree_user&.admin?

    @sync_logs = RepairShoprProductsSyncLog.all.order(created_at: :desc).limit(100) # TODO: paginate instead of limiting to 100
  end

  def new
    SyncRepairShoprJob.perform_later(RepairShoprProductsSyncLog.create!)
    redirect_to admin_syncs_path
  end
end
