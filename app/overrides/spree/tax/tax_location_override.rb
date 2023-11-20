module Spree
  module Tax
    module TaxLocationOverride
      attr_reader :country_id, :state_id, :district_id

      def initialize(country: nil, state: nil, district: nil)
        @country_id = country&.id
        @state_id = state&.id
        @district_id = district&.id
      end

      def ==(other)
        state_id == other.state_id && country_id == other.country_id && district_id == other.district_id
      end

      def empty?
        country_id.nil? && state_id.nil? && district_id.nil?
      end

      Spree::Tax::TaxLocation.prepend self
    end
  end
end