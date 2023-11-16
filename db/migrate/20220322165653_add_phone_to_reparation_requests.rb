class AddPhoneToReparationRequests < ActiveRecord::Migration[6.1]
  def change
    add_column :reparation_requests, :phone, :string
  end
end
