class AddCoordinatesToDisctrict < ActiveRecord::Migration[6.1]
  def change
    add_column :districts, :latitude, :float
    add_column :districts, :longitude, :float
  end
end
