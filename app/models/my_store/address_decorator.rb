# frozen_string_literal: true

module MyStore
  module AddressDecorator
    def self.prepended(base)
      base.belongs_to :district
    end

    def require_zipcode?
      false
    end

    Spree::Address.prepend self
  end
end
