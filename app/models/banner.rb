# frozen_string_literal:true

class Banner < ApplicationRecord
  has_one_attached :photo

  enum location: { shop: 0, reparation: 1 }

  validates :photo, :location, presence: true
  validates :location, uniqueness: { message: ->(banner, _) { "There can be only one \"#{banner.location.capitalize}\" Banner, please edit the one that already exists" } }
end
