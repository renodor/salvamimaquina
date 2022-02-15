class CreateTradeInRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :trade_in_requests do |t|
      t.integer :shop
      t.boolean :with_promo
      t.string :name
      t.string :phone
      t.string :email
      t.text :comment
      t.text :token

      t.references :trade_in_model, null: false, foreign_key: true
      t.integer :variant_id, null: false
      t.foreign_key :spree_variants, column: :variant_id, on_delete: :cascade

      t.timestamps
    end
  end
end
