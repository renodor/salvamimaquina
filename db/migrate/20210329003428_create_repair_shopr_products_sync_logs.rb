class CreateRepairShoprProductsSyncLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :repair_shopr_products_sync_logs do |t|
      t.integer :synced_products, default: 0
      t.integer :deleted_products, default: 0
      t.integer :synced_product_images, default: 0
      t.integer :deleted_product_images, default: 0
      t.integer :synced_product_categories, default: 0
      t.integer :deleted_product_categories, default: 0
      t.string :sync_errors, array: true, default: []
      t.timestamps
    end
  end
end
