# frozen_string_literal: true

module Spree
  class PaymentMethod::BacCreditCard < Spree::PaymentMethod::CreditCard
    def gateway_class
      self.class
    end

    def authorize(amount, source, options)
      response = PaymentGateway::FirstAtlanticCommerce::Authorize.call(
        amount: amount.to_f,
        card_info: {
          number: source[:number].delete(' '),
          expiry_date: source[:expiry].split(' / ').reverse.join,
          cvv: source[:verification_value],
          name: source[:name]
        },
        order_number: options[:order_id],
        email: options[:email],
        billing_address: options[:billing_address]
      )

      ActiveMerchant::Billing::Response.new(
        response[:success],
        response[:message],
        { method_name: 'Auth Request' }, { authorization: response[:response_code] }
      )
    end

    def authorize_3ds(amount, source, options)
      response = PaymentGateway::FirstAtlanticCommerce::Authorize.call(
        order_info: {
          amount: amount.to_f,
          number: options[:order_id],
          transaction_uuid: options[:originator].uuid,
          email: options[:email],
          billing_address: options[:billing_address]
        },
        card_info: {
          number: source[:number].delete(' '),
          expiry_date: source[:expiry].split(' / ').reverse.join,
          cvv: source[:verification_value],
          name: source[:name]
        }
      )

      # TODO: create a response handler that calls ActiveMerchat::Billing::Response.new and call it in every method
      ActiveMerchant::Billing::Response.new(
        response[:success],
        response[:message],
        { html_form: response[:html_form], type: :authorize_3ds_response, method_name: 'Auth3Ds Request' }
      )
    end

    def handle_3ds_response(response)
      valid_eci = response['CardBrand'] == 'MasterCard' ? '02' : '05'
      success   = response['IsoResponseCode'] == '3D0' && response['RiskManagement']['ThreeDSecure']['Eci'] == valid_eci

      ActiveMerchant::Billing::Response.new(
        success,
        response['ResponseMessage'],
        { reason_code: response['IsoResponseCode'], method_name: 'Auth3Ds Response', spi_token: response['SpiToken'] }
      )
    end

    def payment(spi_token)
      response = PaymentGateway::FirstAtlanticCommerce::Payment.call(spi_token: spi_token)
      ActiveMerchant::Billing::Response.new(
        response[:success],
        response[:message],
        { reason_code: response[:reason_code], method_name: 'Payment' }
      )
    end

    # def tokenize(card_number:, customer_reference:, expiry_date:)
    #   response = PaymentGateway::FirstAtlanticCommerce::Tokenize.call(
    #     card_number: card_number,
    #     customer_reference: customer_reference,
    #     expiry_date: expiry_date
    #   )
    #
    #   ActiveMerchant::Billing::Response.new(response[:success], response[:error_message].presence || response[:token])
    # end

    def purchase(_amount, _source, options = {})
      payment(options[:originator].spi_token)
    end

    private

    def fac_formated_amount(amount)
      amount.to_s.delete('.').rjust(12, '0')
    end
  end
end
