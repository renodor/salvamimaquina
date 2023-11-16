class AddGoogleMapLinkToShippingMethod < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_shipping_methods, :google_map_link, :text
  end
end
