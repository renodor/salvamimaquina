# frozen_string_literal: true

module Spree
  module AddressDecorator
    def self.prepended(base)
      base.belongs_to :district, class_name: 'Spree::District', optional: true
      base.before_validation :remove_non_numerical_charaters_from_phone
    end

    def require_zipcode?
      false
    end

    def google_maps_link
      "http://www.google.com/maps/place/#{latitude},#{longitude}"
    end

    def remove_non_numerical_charaters_from_phone
      phone.gsub!(/\D/, '')
    end

    Spree::Address.prepend self
  end
end
