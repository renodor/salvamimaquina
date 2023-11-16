class CreateReparationCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :reparation_categories do |t|
      t.string :name
      t.string :products, array: true, default: []
      t.string :damages, array: true, default: []

      t.timestamps
    end
  end
end
