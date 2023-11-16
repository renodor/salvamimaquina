class DropBanners < ActiveRecord::Migration[6.1]
  def change
    drop_table :banners
  end
end
