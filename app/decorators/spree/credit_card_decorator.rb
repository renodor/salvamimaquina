# frozen_string_literal: true

module Spree
  module CreditCardDecorator
    # Uncomment to make tokenization mandatory
    # def self.prepended(base)
    #   base.validate :validates_token
    # end

    # def validates_token
    #   return if token || !payment_method.instance_of?(Spree::PaymentMethod::BacCreditCard)

    #   errors.add(:base, :invalid_token)
    # end

    def needs_3ds?
      payment_method.type == 'Spree::PaymentMethod::BacCreditCard' && %w[visa master].include?(cc_type)
    end

    Spree::CreditCard.prepend self
  end
end
