class CreateTradeInModels < ActiveRecord::Migration[6.1]
  def change
    create_table :trade_in_models do |t|
      t.column :name, :string
      t.column :min_value, :float
      t.column :max_value, :float
      t.references :trade_in_category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
