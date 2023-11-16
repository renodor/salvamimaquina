class AddTextsToBanner < ActiveRecord::Migration[6.1]
  def change
    add_column :banners, :text_one, :text
    add_column :banners, :text_two, :text
    add_column :banners, :text_three, :text
  end
end
