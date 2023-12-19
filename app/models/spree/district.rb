# frozen_string_literal: true

module Spree
  class District < ApplicationRecord
    belongs_to :state, class_name: 'Spree::State'

    def district_with_state
      "#{name} (#{state})"
    end
  end
end
