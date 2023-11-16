class AddOrderToTradeInModels < ActiveRecord::Migration[6.1]
  def change
    add_column :trade_in_models, :order, :integer
  end
end
