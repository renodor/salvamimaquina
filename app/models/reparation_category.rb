# frozen_string_literal:true

class ReparationCategory < ApplicationRecord
  has_many :reparation_requests

  validates :name, presence: true
end
