# frozen_string_literal:true

class TradeInRequest < ApplicationRecord
  belongs_to :trade_in_model
  belongs_to :spree_variant

  validates :shop, :name, :phone, :email, presence: true
end
