# frozen_string_literal:true

class Slider < ApplicationRecord
  has_many_attached :slide_images

  enum location: { corporate_clients: 0 }

  validates :name, :slide_images, :location, presence: true
  validates :location, uniqueness: { message: ->(banner, _) { "There can be only one \"#{banner.location.capitalize}\" Banner, please edit the one that already exists" } }
end
