class CreateDistricts < ActiveRecord::Migration[6.1]
  def change
    create_table :districts do |t|
      t.string :name

      t.integer :state_id, null: false
      t.foreign_key :spree_states, column: :state_id, on_delete: :cascade

      t.timestamps
    end
  end
end
