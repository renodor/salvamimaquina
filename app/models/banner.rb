# frozen_string_literal:true

class Banner < ApplicationRecord
  CLOUDINARY_STORAGE_FOLDER = 'banners'

  has_one_attached :photo, service: :cloudinary_banners

  enum location: { shop: 0, reparation: 1, corporate_clients: 2 }

  validates :photo, :location, presence: true
  validates :location, uniqueness: { message: ->(banner, _) { "There can be only one \"#{banner.location.capitalize}\" Banner, please edit the one that already exists" } }

  def texts
    [text_one, text_two, text_three]
  end

  def any_text?
    texts.any?(&:present?)
  end
end
