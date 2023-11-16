class AddRepairShoprIdToStockLocation < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_stock_locations, :repair_shopr_id, :integer
  end
end