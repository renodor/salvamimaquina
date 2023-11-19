# frozen_string_literal:true

class ReparationCategory < ApplicationRecord
  CLOUDINARY_STORAGE_FOLDER = 'reparation_categories'
  CLOUDINARY_FALLBACK_IMAGE = 'reparation-category-placeholder.jpg'

  has_many :reparation_requests, dependent: :destroy
  has_one_attached :photo, service: :cloudinary_reparation_categories

  validates :name, :products, :damages, presence: true
end
