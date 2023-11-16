class CreateTradeInCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :trade_in_categories do |t|
      t.column :name, :string
      t.column :order, :integer

      t.timestamps
    end
  end
end
