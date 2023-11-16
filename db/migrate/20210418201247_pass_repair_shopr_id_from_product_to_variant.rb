class PassRepairShoprIdFromProductToVariant < ActiveRecord::Migration[6.1]
  def change
    remove_column :spree_products, :repair_shopr_id, :integer
    add_column :spree_variants, :repair_shopr_id, :integer
  end
end
