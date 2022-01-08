# frozen_string_literal:true

class Slider < ApplicationRecord
  has_many_attached :slide_images
  has_many_attached :mobile_slide_images

  enum location: { corporate_clients: 0, home_page: 1 }

  validates :name, :slide_images, :location, presence: true
  validates :location, uniqueness: { message: ->(slider, _) { "There can be only one \"#{slider.location.capitalize}\" Slider, please edit the one that already exists" } }
end
