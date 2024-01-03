# frozen_string_literal: true

module Spree
  class PaymentMethod::BacCreditCard < PaymentMethod::CreditCard
    def gateway_class
      self.class
    end

    def sale(amount, source, options)
      response = PaymentGateway::FirstAtlanticCommerce::Sale.new(
        order_info: {
          amount: amount.to_f / 100,
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
      ).call

      active_merchant_response(
        response[:success],
        response[:message],
        {
          html_form: response[:html_form],
          iso_response_code: response[:iso_response_code],
          method_name: 'Sale'
        }
      )
    end

    def handle_3ds_response(response)
      authentication_status = response.dig('RiskManagement', 'ThreeDSecure', 'AuthenticationStatus')
      iso_response_code     = response['IsoResponseCode']

      active_merchant_response(
        iso_response_code == '3D0' && %w[Y A U].include?(authentication_status),
        response['ResponseMessage'],
        {
          spi_token: response['SpiToken'],
          iso_response_code: iso_response_code,
          three_ds_status: authentication_status,
          method_name: '3Ds Response'
        }
      )
    end

    def payment(spi_token)
      response = PaymentGateway::FirstAtlanticCommerce::Payment.new(spi_token: spi_token).call

      active_merchant_response(
        response[:success],
        response[:message],
        {
          iso_response_code: response[:iso_response_code],
          method_name: 'Payment'
        }
      )
    end

    def purchase(_amount, _source, options = {})
      spi_token = options[:originator].spi_token

      # Prevent from calling payment endpoint without a valid spi token, which would raise an exception...
      if spi_token
        payment(spi_token)
      else
        active_merchant_response(
          false,
          'Unable to retrieve Spi Token',
          { method_name: 'Payment' }
        )
      end
    end

    private

    def active_merchant_response(success, message, params)
      ActiveMerchant::Billing::Response.new(success, message, params)
    end
  end
end
