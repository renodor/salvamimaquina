# frozen_string_literal: true

module Spree
  module PaymentCreateDecorator
    def build_source
      super

      # If using BAC payment gateway we need to tokenize the credit card
      # so that we can store it following PCI compliance and proceed payment later
      tokenize_credit_card if payment.payment_method.instance_of?(Spree::PaymentMethod::BacCreditCard)
    end

    def tokenize_credit_card
      response = payment.payment_method.tokenize(
        card_number: source_attributes[:number].delete(' '),
        customer_reference: @order.email, # This customer reference is used by FAC and should be unique per customer (card holder)
        expiry_date: source_attributes[:expiry].delete(' / ')
      )

      if response.success?
        payment.source.update!(
          token: response.message,
          encoded_cvv: Base64.encode64(source_attributes[:verification_value])
        )
      else
        # TODO: add error to payment source so that order has errors and won't transition forward
      end
    end

    Spree::PaymentCreate.prepend self
  end
end