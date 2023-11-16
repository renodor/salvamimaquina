class CreateSliders < ActiveRecord::Migration[6.1]
  def change
    create_table :sliders do |t|
      t.column :location, :integer
      t.column :name, :string
      t.timestamps
    end
  end
end
