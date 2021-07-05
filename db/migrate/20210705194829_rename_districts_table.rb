class RenameDistrictsTable < ActiveRecord::Migration[6.1]
  def change
    rename_table :districts, :spree_districts
  end
end
