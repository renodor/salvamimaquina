class AddAltToSlides < ActiveRecord::Migration[6.1]
  def change
    add_column :slides, :alt, :string, default: ''
  end
end
