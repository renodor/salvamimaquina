# frozen_string_literal: true

module Spree
  class PaymentMethod::BacCreditCard < Spree::PaymentMethod::CreditCard
    def gateway_class
      self.class
    end

    def authorize(money, source, options = {})
      response = PaymentGateway::FirstAtlanticCommerce::Authorize.call(money, source, options)
      if response.success?
        ActiveMerchant::Billing::Response.new(true, "Transaction approved", {}, authorization: response.id)
      else
        ActiveMerchant::Billing::Response.new(false, response.error.message)
      end
    end

    def capture(_money, charge_id, _options = {})
      response = ::Affirm::Charge.capture(charge_id)
      if response.success?
        ActiveMerchant::Billing::Response.new(true, "Transaction Captured", {}, authorization: charge_id)
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
      result = authorize(money, source, options)
      return result unless result.success?
      capture(money, result.authorization, _options)
    end

    def tokenize(card_number:, customer_reference:, expiry_date:)
      PaymentGateway::FirstAtlanticCommerce::Tokenize.call(
        card_number: card_number,
        customer_reference: customer_reference,
        expiry_date: expiry_date
      )
    end
  end
end
