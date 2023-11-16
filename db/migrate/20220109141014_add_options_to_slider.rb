class AddOptionsToSlider < ActiveRecord::Migration[6.1]
  def change
    add_column :sliders, :navigation, :boolean, default: false
    add_column :sliders, :pagination, :boolean, default: false
    add_column :sliders, :auto_play, :boolean, default: true
    add_column :sliders, :delay_between_slides, :integer, default: 3000
    add_column :sliders, :image_per_slide_xl, :integer, default: 1
    add_column :sliders, :image_per_slide_l, :integer, default: 1
    add_column :sliders, :image_per_slide_m, :integer, default: 1
    add_column :sliders, :image_per_slide_s, :integer, default: 1
  end
end
