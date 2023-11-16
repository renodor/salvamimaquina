# frozen_string_literal:true

class ReparationRequest < ApplicationRecord
  belongs_to :reparation_category

  validates :product, :damage, :shop, :name, :email, :phone, :comment, presence: true
  validates :email, format: { with: /\A\S+@\S+\.\S+\z/i }

  enum shop: { bella_vista: 0, san_francisco: 1 }
end