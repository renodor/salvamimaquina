# frozen_string_literal:true

class TradeInModel < ApplicationRecord
  belongs_to :trade_in_category

  validates :name, :min_value, :max_value, presence: true
end