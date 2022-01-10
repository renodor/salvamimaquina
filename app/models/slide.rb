# frozen_string_literal:true

class Slide < ApplicationRecord
  belongs_to :slider
  has_one_attached :image
  has_one_attached :image_mobile

  validates :image, presence: true
end
