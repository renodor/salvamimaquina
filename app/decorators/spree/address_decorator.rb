# frozen_string_literal: true

module Spree
  module AddressDecorator
    def self.prepended(base)
      base.belongs_to :district, class_name: 'Spree::District', optional: true
    end

    def require_zipcode?
      false
    end

    def google_maps_link
      "http://www.google.com/maps/place/#{latitude},#{longitude}"
    end

    Spree::Address.prepend self
  end
end
