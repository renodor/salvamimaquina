# frozen_string_literal:true

class Slider < ApplicationRecord
  has_many :slides, dependent: :destroy

  enum location: { corporate_clients: 0, home_page: 1 }

  validates :name, :location, :delay_between_slides, :image_per_slide_xl, :image_per_slide_l, :image_per_slide_m, :image_per_slide_s, :space_between_slides, presence: true
  validates :location, uniqueness: { message: ->(slider, _) { "has to be unique. There is already one \"#{slider.location}\" slider, please edit the one that already exists" } }
end
