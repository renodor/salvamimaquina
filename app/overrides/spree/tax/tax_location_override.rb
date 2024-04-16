# frozen_string_literal: true

module Spree
  module Tax
    module TaxLocationOverride
      attr_reader :country, :state, :district

      def initialize(country: nil, state: nil, district: nil)
        @country = country
        @state = state
        @district = district
      end
      delegate :id, to: :state, prefix: true, allow_nil: true
      delegate :id, to: :country, prefix: true, allow_nil: true
      delegate :id, to: :district, prefix: true, allow_nil: true

      def ==(other)
        state == other.state && country == other.country && district == other.district
      end

      def empty?
        country_id.nil? && state_id.nil? && district_id.nil?
      end

      Spree::Tax::TaxLocation.prepend self
    end
  end
end
