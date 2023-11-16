class AddRepairShoprIdToImage < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_assets, :repair_shopr_id, :integer
  end
end
