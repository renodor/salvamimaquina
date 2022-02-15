# frozen_string_literal:true

class TradeInRequest < ApplicationRecord
  belongs_to :trade_in_model
  belongs_to :variant, class_name: 'Spree::Variant'

  validates :shop, :name, :phone, :email, presence: true

  enum shop: { bella_vista: 0, san_francisco: 1 }

  before_create :set_with_promo
  before_create :generate_token

  COUPON_VALIDITY_DAYS = 7

  def coupon_code
    "TRADE-IN-#{token[0, 5]}"
  end

  private

  def set_with_promo
    self.with_promo = !TradeInRequest.exists?(email: email)
  end

  def generate_token
    token = nil
    loop do
      token = SecureRandom.hex(8)

      break unless TradeInRequest.find_by(token: token)
    end

    self.token = token
  end
end
