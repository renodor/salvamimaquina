class AddConditionToVariant < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_variants, :condition, :integer, default: 0
  end
end
