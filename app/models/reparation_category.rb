# frozen_string_literal:true

class ReparationCategory < ApplicationRecord
  has_many :reparation_requests
  has_one_attached :photo

  validates :name, :products, :damages, presence: true
end
