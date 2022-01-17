# frozen_string_literal:true

class Slide < ApplicationRecord
  CLOUDINARY_STORAGE_FOLDER = 'slides'
  VALID_IMAGE_TYPES = ['image/png', 'image/jpg', 'image/jpeg', 'image/webp'].freeze

  belongs_to :slider
  has_one_attached :image, service: :cloudinary_slides
  has_one_attached :image_mobile, service: :cloudinary_slides

  validates :image, presence: true
  validate :correct_image_type

  private

  def correct_image_type
    errors.add(:image, 'Must be an image file') if image.attached? && !VALID_IMAGE_TYPES.include?(image.content_type)
    errors.add(:image_mobile, 'Must be an image file') if image_mobile.attached? && !VALID_IMAGE_TYPES.include?(image_mobile.content_type)
  end
end
