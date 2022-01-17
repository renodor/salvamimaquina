# frozen_string_literal:true

class ReparationCategory < ApplicationRecord
  CLOUDINARY_STORAGE_FOLDER = 'reparation_categories'

  has_many :reparation_requests
  has_one_attached :photo, service: :cloudinary_reparation_categories

  validates :name, :products, :damages, presence: true
end
