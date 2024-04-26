class DropSalePriceGemTables < ActiveRecord::Migration[7.0]
  def change
    drop_table :spree_sale_prices, id: :serial do |t|
      t.integer "price_id"
      t.decimal "value", precision: 10, scale: 2, null: false
      t.datetime "start_at", precision: nil
      t.datetime "end_at", precision: nil
      t.boolean "enabled"
      t.datetime "deleted_at", precision: nil
      t.decimal "calculated_price", precision: 10, scale: 2
      t.index ["deleted_at"], name: "index_spree_sale_prices_on_deleted_at"
      t.index ["price_id", "start_at", "end_at", "enabled"], name: "index_active_sale_prices_for_price"
      t.index ["price_id"], name: "index_sale_prices_for_price"
      t.index ["start_at", "end_at", "enabled"], name: "index_active_sale_prices_for_all_variants"

      t.timestamps precision: nil
    end
  end
end
