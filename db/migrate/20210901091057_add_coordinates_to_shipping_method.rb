class AddCoordinatesToShippingMethod < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_shipping_methods, :latitude, :float
    add_column :spree_shipping_methods, :longitude, :float
  end
end