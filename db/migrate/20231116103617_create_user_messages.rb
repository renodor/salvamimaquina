class CreateUserMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :user_messages do |t|
      t.string :email
      t.string :name
      t.text :message

      t.timestamps
    end
  end
end
