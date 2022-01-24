# frozen_string_literal:true

class TradeInCategory < ApplicationRecord
  CLOUDINARY_STORAGE_FOLDER = 'trade-in_categories'
  CLOUDINARY_FALLBACK_IMAGE = 'trade-in-category-placeholder.jpg'

  has_many :trade_in_models, dependent: :destroy
  has_one_attached :photo, service: :cloudinary_trade_in_categories

  validates :name, presence: true
  validates :name, uniqueness: true
end
