class CreateBanners < ActiveRecord::Migration[6.1]
  def change
    create_table :banners do |t|
      t.column :location, :integer
      t.timestamps
    end
  end
end
