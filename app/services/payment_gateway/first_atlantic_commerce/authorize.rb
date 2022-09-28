# frozen_string_literal: true

module PaymentGateway
  module FirstAtlanticCommerce
    class Authorize < FirstAtlanticCommerce::Base
      class << self
        def call(order_info:, card_info:)
          response = authorize(json_payload(order_info: order_info, card_info: card_info))

          response_code = response[:IsoResponseCode]

          {
            success: response_code == 'SP4',
            response_code: response_code,
            message: response[:ResponseMessage],
            html_form: response[:RedirectData]
          }
        end

        private

        def json_payload(order_info:, card_info:)
          {
            TransactionIdentifier: order_info[:transaction_uuid],
            TotalAmount: order_info[:amount],
            CurrencyCode: FirstAtlanticCommerce::Base::PURCHASE_CURRENCY,
            ThreeDSecure: true,
            Source: {
              CardPan: card_info[:number],
              CardCvv: card_info[:cvv],
              CardExpiration: card_info[:expiry_date],
              CardholderName: card_info[:name]
            },
            OrderIdentifier: order_info[:number],
            BillingAddress: {
              FirstName: order_info[:billing_address][:name].split[0],
              LastName: order_info[:billing_address][:name].split[1],
              Line1: order_info[:billing_address][:address1],
              Line2: order_info[:billing_address][:address2],
              City: order_info[:billing_address][:city],
              County: 'Panamá',
              CountryCode: 591,
              EmailAddress: order_info[:email]
            },
            ExtendedData: {
              ThreeDSecure: {
                ChallengeWindowSize: 5,
                MerchantResponseUrl: '01'
              },
              MerchantResponseUrl: "https://#{Rails.env.production? ? 'www.salvamimaquina.com' : 'a8e3-185-146-220-58.ngrok.io'}/checkout/three_d_secure_response"
            }
          }.to_json
        end
      end
    end
  end
end
