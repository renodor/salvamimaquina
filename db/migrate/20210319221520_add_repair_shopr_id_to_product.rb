class AddRepairShoprIdToProduct < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_products, :repair_shopr_id, :integer
  end
end
