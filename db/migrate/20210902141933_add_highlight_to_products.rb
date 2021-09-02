class AddHighlightToProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_products, :highlight, :boolean, default: false
  end
end
