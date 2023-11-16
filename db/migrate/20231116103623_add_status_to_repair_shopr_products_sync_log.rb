class AddStatusToRepairShoprProductsSyncLog < ActiveRecord::Migration[6.1]
  def change
    add_column :repair_shopr_products_sync_logs, :status, :integer, default: 0
  end
end
