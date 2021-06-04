# frozen_string_literal: true

module Spree
  module CreditCardDecorator
    # Uncomment to make credit card tokenization mandatory

    # def self.prepended(base)
    #   base.validate :validates_token
    # end

    # def validates_token
    #   return if token || !payment_method.instance_of?(Spree::PaymentMethod::BacCreditCard)

    #   errors.add(:base, :invalid_token)
    # end

    # Spree::CreditCard.prepend self
  end
end
