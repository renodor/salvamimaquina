# frozen_string_literal:true

class Slide < ApplicationRecord
  VALID_IMAGE_TYPES = ['image/png', 'image/jpg', 'image/jpeg'].freeze
  belongs_to :slider
  has_one_attached :image
  has_one_attached :image_mobile

  validates :image, presence: true
  validate :correct_image_type

  private

  def correct_image_type
    errors.add(:image, 'Must be an image file') if image.attached? && !VALID_IMAGE_TYPES.include?(image.content_type)
    errors.add(:image_mobile, 'Must be an image file') if image_mobile.attached? && !VALID_IMAGE_TYPES.include?(image_mobile.content_type)
  end
end
