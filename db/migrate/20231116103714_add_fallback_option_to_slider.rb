class AddFallbackOptionToSlider < ActiveRecord::Migration[6.1]
  def change
    add_column :sliders, :fallback_image, :boolean, default: true
  end
end
