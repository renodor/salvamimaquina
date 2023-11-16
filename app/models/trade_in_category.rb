# frozen_string_literal:true

class TradeInCategory < ApplicationRecord
  has_many :trade_in_models, dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: true
end