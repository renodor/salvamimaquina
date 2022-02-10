class CreateTradeInRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :trade_in_requests do |t|
      t.references :trade_in_model, null: false, foreign_key: true
      t.references :spree_variant, null: false, foreign_key: true
      t.integer :shop
      t.string :name
      t.string :phone
      t.string :email
      t.string :coupon_code

      t.timestamps
    end
  end
end
