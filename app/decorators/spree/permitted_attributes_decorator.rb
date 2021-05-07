# frozen_string_literal: true

module Spree
  module PermittedAttributesDecorator

    # Adding district_id to Spree::Address permited attributes
    @@address_attributes = [
      :id, :name, :address1, :address2, :city, :country_id, :state_id, :district_id,
      :zipcode, :phone, :state_name, :country_iso, :alternative_phone, :company,
      country: [:iso, :name, :iso3, :iso_name],
      state: [:name, :abbr]
    ]

    Spree::PermittedAttributes.prepend self
  end
end
