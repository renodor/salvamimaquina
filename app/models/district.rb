# frozen_string_literal: true

class District < ApplicationRecord
  belongs_to :state, class_name: 'Spree::State'
end
