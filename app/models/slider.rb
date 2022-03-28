# frozen_string_literal:true

class Slider < ApplicationRecord
  has_many :slides, dependent: :destroy

  enum location: {
    corporate_clients: 0,
    home_page: 1,
    products: 2,
    trade_in: 3,
    reparation: 4
  }

  validates :name, :location, :delay_between_slides, :image_per_slide_xl, :image_per_slide_l, :image_per_slide_m, :image_per_slide_s, :space_between_slides, presence: true
  validates :location, uniqueness: { message: ->(slider, _) { "has to be unique. There is already one \"#{slider.location}\" slider, please edit the one that already exists" } }

  def slide_sizes_by_slider_location
    case location
    when 'home_page'
      {
        desktop: {
          width: 1300,
          height: 550
        },
        mobile: {
          width: 535,
          height: 535
        }
      }
    when 'corporate_clients'
      {
        desktop: {
          width: 150,
          height: 150
        },
        mobile: {
          width: 150,
          height: 150
        }
      }
    else
      {
        desktop: {
          width: 1300,
          height: 250
        },
        mobile: {
          width: 535,
          height: 250
        }
      }
    end
  end
end
