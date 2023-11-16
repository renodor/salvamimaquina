class AddOtherOptionsToSlider < ActiveRecord::Migration[6.1]
  def change
    add_column :sliders, :space_between_slides, :integer, default: 10
    add_column :sliders, :force_slide_full_width, :boolean, default: true
  end
end
