# frozen_string_literal: true

module MyStore
  module AddressDecorator
    def require_zipcode?
      false
    end

    Spree::Address.prepend self
  end
end
