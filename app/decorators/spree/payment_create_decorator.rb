# frozen_string_literal: true

module Spree
  module PaymentCreateDecorator
    # def build_source
    #   super

    #   # If using BAC payment gateway we need to tokenize the credit card
    #   # so that we can store it following PCI compliance and proceed payment later
    #   # tokenize_credit_card if payment.payment_method.instance_of?(Spree::PaymentMethod::BacCreditCard)
    # end

    # def tokenize_credit_card
    #   # Call the tokenize method on Spree::PaymentMethod::BacCreditCard
    #   response = payment.payment_method.tokenize(
    #     card_number: source_attributes[:number].delete(' '),
    #     customer_reference: @order.email, # This customer reference is used by FAC and should be unique per customer (card holder)
    #     expiry_date: source_attributes[:expiry].delete(' / ')
    #   )

    #   payment_source = payment.source
    #   # We need to save the cvv to process payment later
    #   payment_source.encoded_cvv = Base64.encode64(source_attributes[:verification_value])
    #   # If cc have been correctly tokenized, add the token to the payment source
    #   # If not, payment source won't have a token, so it won't be valid, and order won't proceed to next state
    #   payment_source.token = response.message if response.success?
    # end

    Spree::PaymentCreate.prepend self
  end
end
