class AddProductToReparationRequests < ActiveRecord::Migration[6.1]
  def change
    add_column :reparation_requests, :product, :string
  end
end
