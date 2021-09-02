# frozen_string_literal:true

class ReparationRequest < ApplicationRecord
  belongs_to :reparation_category

  validates :damage, :shop, :name, :email, :comment, presence: true

  enum shop: { bella_vista: 0, san_francisco: 1 }
end
