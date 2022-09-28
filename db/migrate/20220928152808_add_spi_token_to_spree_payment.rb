class AddSpiTokenToSpreePayment < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_payments, :spi_token, :string
  end
end
