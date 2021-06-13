# frozen_string_literal: true

module Spree
  class PaymentMethod::BacCreditCard < Spree::PaymentMethod::CreditCard
    def gateway_class
      self.class
    end

    def authorize(amount, source, options)
      response = PaymentGateway::FirstAtlanticCommerce::Authorize.call(
        amount: fac_formated_amount(amount),
        card_number: source[:number].delete(' '),
        card_expiry_date: source[:expiry].delete(' / '),
        card_cvv: source[:verification_value],
        order_number: options[:order_id]
      )

      ActiveMerchant::Billing::Response.new(response[:success], response[:message], {}, { authorization: response[:response_code] })
    end

    def authorize_3ds(amount, source, options)
      response = PaymentGateway::FirstAtlanticCommerce::Authorize3ds.call(
        amount: fac_formated_amount(amount),
        card_number: source[:number].delete(' '),
        card_expiry_date: source[:expiry].delete(' / '),
        card_cvv: source[:verification_value],
        order_number: options[:order_id]
      )

      ActiveMerchant::Billing::Response.new(response[:success], response[:message], { html_form: response[:html_form], type: :authorize_3ds_response })
    end

    def handle_3ds_response(response)
      ActiveMerchant::Billing::Response.new(response['ResponseCode'] == '1', response['ReasonCodeDesc'], { reason_code: response['ReasonCode'] })
    end

    def capture(amount, order_number)
      response = PaymentGateway::FirstAtlanticCommerce::Capture.call(amount: fac_formated_amount(amount), order_number: order_number)
      ActiveMerchant::Billing::Response.new(response[:success], response[:message], { reason_code: response[:reason_code] })
    end

    def tokenize(card_number:, customer_reference:, expiry_date:)
      response = PaymentGateway::FirstAtlanticCommerce::Tokenize.call(
        card_number: card_number,
        customer_reference: customer_reference,
        expiry_date: expiry_date
      )

      ActiveMerchant::Billing::Response.new(response[:success], response[:error_message].presence || response[:token])
    end

    def purchase(amount, _source, options = {})
      capture(amount, options[:order_id])
    end

    private

    def fac_formated_amount(amount)
      amount.to_s.delete('.').rjust(12, '0')
    end
  end
end
