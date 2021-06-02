# frozen_string_literal: true

module Spree
  class PaymentMethod::BacCreditCard < Spree::PaymentMethod::CreditCard
    def gateway_class
      self.class
    end

    def authorize3ds(amount, source, order_number)
      response = PaymentGateway::FirstAtlanticCommerce::Authorize3ds.call(
        amount: amount,
        card_number: source[:number].delete(' '),
        card_expiry_date:  source[:expiry].delete(' / '),
        card_cvv: source[:verification_value],
        order_number: order_number
      )
      ActiveMerchant::Billing::Response.new(response[:success], '3ds html form', { html_form: response[:html_form] })
    end

    def capture(_money, charge_id, _options = {})
      response = ::Affirm::Charge.capture(charge_id)
      if response.success?
        ActiveMerchant::Billing::Response.new(true, 'Transaction Captured', {}, authorization: charge_id)
      else
        ActiveMerchant::Billing::Response.new(false, response.error.message)
      end
    end

    def void(charge_id, _money, _options = {})
      response = ::Affirm::Charge.void(charge_id)
      if response.success?
        return ActiveMerchant::Billing::Response.new(true, "Transaction Voided")
      else
        return ActiveMerchant::Billing::Response.new(false, response.error.message)
      end
    end

    def credit(money, charge_id, _options = {})
      response = ::Affirm::Charge.refund(charge_id, amount: money)
      if response.success?
        return ActiveMerchant::Billing::Response.new(true, "Transaction Credited with #{money}")
      else
        return ActiveMerchant::Billing::Response.new(false, response.error.message)
      end
    end

    def purchase(money, source, options = {})
      # result = authorize3ds(money, source, options)
      # return result unless result.success?
      # capture(money, result.authorization, _options)
      ActiveMerchant::Billing::Response.new(true, 'Fake Success')
    end

    def tokenize(card_number:, customer_reference:, expiry_date:)
      response = PaymentGateway::FirstAtlanticCommerce::Tokenize.call(
        card_number: card_number,
        customer_reference: customer_reference,
        expiry_date: expiry_date
      )

      ActiveMerchant::Billing::Response.new(response[:success], response[:error_message].presence || response[:token])
    end
  end
end
