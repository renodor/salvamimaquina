# frozen_string_literal: true

module PaymentGateway
  module FirstAtlanticCommerce
    class Sale
      include Client

      PURCHASE_CURRENCY = 840 # FAC code for USD
      COUNTRY_CODE      = 591 # ISO 3166 country code of Panama

      def initialize(order_info:, card_info:)
        @order_info = order_info
        @card_info  = card_info
      end

      def call
        response = request(http_method: :post, endpoint: 'sale', params: payload)
        response_code = response[:IsoResponseCode]

        {
          success: response_code == 'SP4',
          iso_response_code: response_code,
          message: response[:ResponseMessage],
          html_form: response[:RedirectData]
        }
      end

      private

      def payload
        {
          TransactionIdentifier: @order_info[:transaction_uuid],
          TotalAmount: @order_info[:amount],
          CurrencyCode: PURCHASE_CURRENCY,
          ThreeDSecure: true,
          Source: {
            CardPan: @card_info[:number],
            CardCvv: @card_info[:cvv],
            CardExpiration: @card_info[:expiry_date],
            CardholderName: @card_info[:name]
          },
          OrderIdentifier: @order_info[:number],
          BillingAddress: {
            FirstName: @order_info[:billing_address][:name].split[0],
            LastName: @order_info[:billing_address][:name].split[1],
            Line1: @order_info[:billing_address][:address1],
            Line2: @order_info[:billing_address][:address2],
            City: @order_info[:billing_address][:city],
            County: 'Panamá',
            CountryCode: COUNTRY_CODE,
            EmailAddress: @order_info[:email]
          },
          ExtendedData: {
            ThreeDSecure: {
              ChallengeWindowSize: 5,
              MerchantResponseUrl: '01'
            },
            MerchantResponseUrl: "https://#{Rails.env.production? ? 'www.salvamimaquina.com' : '12ef-2a02-842a-f751-4c01-fe98-f57f-8039-1532.ngrok-free.app'}/checkout/three_d_secure_response"
          }
        }.to_json
      end
    end
  end
end
