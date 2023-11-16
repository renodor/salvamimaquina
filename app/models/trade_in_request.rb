# frozen_string_literal:true

class TradeInRequest < ApplicationRecord
  belongs_to :variant, class_name: 'Spree::Variant'

  validates :model_name_with_options, :model_min_value, :model_max_value, :shop, :name, :phone, :email, presence: true
  validates :email, format: { with: /\A\S+@\S+\.\S+\z/i }

  enum shop: { bella_vista: 0, san_francisco: 1 }

  before_create :set_with_promo
  before_create :generate_token

  COUPON_VALIDITY_DAYS = 7

  def coupon_code
    "TRADE-IN-#{token[0, 5]}".upcase
  end

  def still_valid?
    return false unless with_promo

    Time.current <= created_at + COUPON_VALIDITY_DAYS.days
  end

  def min_value
    variant&.price.to_f - model_max_value
  end

  def max_value
    variant&.price.to_f - model_min_value
  end

  # TODO: maybe store those addresses somewhere... We are using it in different places of the code
  def shop_address
    case shop
    when 'bella_vista'
      'https://www.google.com/maps/place/Salva+Mi+Maquina+%7C+Bella+Vista/@8.9805139,-79.529011,17z/data=!3m1!4b1!4m5!3m4!1s0x8faca8fb88936ebb:0x56016f2bcd0f178d!8m2!3d8.9805139!4d-79.5268223'
    when 'san_francisco'
      'https://www.google.com/maps/place/Salva+Mi+Maquina+%7C+San+Francisco/@8.9946759,-79.504031,17z/data=!3m1!4b1!4m5!3m4!1s0x8faca91d36aa9129:0x160543d69b5ca01f!8m2!3d8.9947064!4d-79.5018527'
    end
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