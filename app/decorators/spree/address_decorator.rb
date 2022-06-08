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

    # RS seems to remove non numerical characters from phone number when creating an user
    # so users with phone = "abcd" will end up with phone = "" and creation will fail because phone can't be empty
    # we add the same validation on address phone to avoid errors when creating RS users during invoice creation
    # (If user tries to put "abcd" in its address phone, address creation will fail and he won't be able to proceed to checkout)
    def remove_non_numerical_charaters_from_phone
      phone.gsub!(/\D/, '')
    end

    Spree::Address.prepend self
  end
end
