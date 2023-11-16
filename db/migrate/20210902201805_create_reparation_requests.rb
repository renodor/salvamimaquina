class CreateReparationRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :reparation_requests do |t|
      t.references :reparation_category, null: false, foreign_key: true
      t.string :damage
      t.integer :shop
      t.string :name
      t.string :email
      t.text :comment

      t.timestamps
    end
  end
end
