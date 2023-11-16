class AddDistrictIdToAddress < ActiveRecord::Migration[6.1]
  def change
    add_reference :spree_addresses, :district, index: true
  end
end
