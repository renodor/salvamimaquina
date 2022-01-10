class CreateSlide < ActiveRecord::Migration[6.1]
  def change
    create_table :slides do |t|

      t.text :link
      t.references :slider, null: false, foreign_key: true
      t.timestamps
    end
  end
end
