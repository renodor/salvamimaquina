class AddRepairShoprNameToVariant < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_variants, :repair_shopr_name, :string
  end
end
