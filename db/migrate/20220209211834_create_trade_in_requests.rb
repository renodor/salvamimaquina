class CreateTradeInRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :trade_in_requests do |t|
      t.integer :shop
      t.boolean :with_promo
      t.string :name
      t.string :phone
      t.string :email
      t.string :model_name_with_options
      t.float :model_min_value
      t.float :model_max_value
      t.text :comment
      t.text :token

      t.integer :variant_id, null: false
      t.foreign_key :spree_variants, column: :variant_id, on_delete: :cascade

      t.timestamps
    end
  end
end
