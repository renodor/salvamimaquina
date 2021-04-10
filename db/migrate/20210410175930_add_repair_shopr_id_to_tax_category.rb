class AddRepairShoprIdToTaxCategory < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_tax_categories, :repair_shopr_id, :integer
  end
end