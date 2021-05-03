# frozen_string_literal: true

class District < ApplicationRecord
  belongs_to :spree_state, class_name: 'Spree::State'
end
