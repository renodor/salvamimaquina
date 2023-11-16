class SolidusMigrationChanges < ActiveRecord::Migration[7.0]
  def change
    add_column :active_storage_blobs, :service_name, :string, null: false
  end
end
