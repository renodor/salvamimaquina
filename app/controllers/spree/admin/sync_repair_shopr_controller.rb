# frozen_string_literal:true

module Spree
  module Admin
    class SyncRepairShoprController < Spree::Admin::BaseController
      def index
        @sync_logs = RepairShoprProductsSyncLog.order(created_at: :desc).page(params[:page])
      end

      def new
        SyncRepairShoprProductsJob.perform_later(RepairShoprProductsSyncLog.create!)
        redirect_to admin_sync_repair_shopr_index_path
      end
    end
  end
end
