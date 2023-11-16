class AddOrderToSlides < ActiveRecord::Migration[6.1]
  def change
    add_column :slides, :order, :integer
  end
end
