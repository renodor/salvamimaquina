class AddPurchaseCountToProduct < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_products, :purchase_count, :integer, default: 0
  end
end
