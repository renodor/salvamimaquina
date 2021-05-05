# frozen_string_literal: true

module Spree
  module AddressDecorator
    def self.prepended(base)
      base.belongs_to :district, optional: true
    end

    def require_zipcode?
      false
    end

    Spree::Address.prepend self
  end
end
