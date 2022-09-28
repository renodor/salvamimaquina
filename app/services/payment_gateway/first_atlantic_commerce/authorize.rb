# frozen_string_literal: true

module PaymentGateway
  module FirstAtlanticCommerce
    class Authorize < FirstAtlanticCommerce::Base
      class << self
        def call(amount:, card_info:, order_number:, email:, billing_address:, transaction_uuid:)
          response = authorize(json_payload(amount, card_info, order_number, email, billing_address, transaction_uuid))

          response_code = response[:IsoResponseCode]

          {
            success: response_code == 'SP4',
            response_code: response_code,
            message: response[:ResponseMessage],
            html_form: response[:RedirectData]
          }
        end

        private

        def json_payload(amount, card_info, order_number, email, billing_address, transaction_uuid)
          {
            TransactionIdentifier: transaction_uuid,
            TotalAmount: amount,
            CurrencyCode: FirstAtlanticCommerce::Base::PURCHASE_CURRENCY,
            ThreeDSecure: true,
            Source: {
              CardPan: card_info[:number],
              CardCvv: card_info[:cvv],
              CardExpiration: card_info[:expiry_date],
              CardholderName: card_info[:name]
            },
            OrderIdentifier: order_number,
            BillingAddress: {
              FirstName: billing_address[:name].split[0],
              LastName: billing_address[:name].split[1],
              Line1: billing_address[:address1],
              Line2: billing_address[:address2],
              City: billing_address[:city],
              County: 'Panamá',
              CountryCode: 591,
              EmailAddress: email
            },
            ExtendedData: {
              ThreeDSecure: {
                ChallengeWindowSize: 5,
                MerchantResponseUrl: '01'
              },
              MerchantResponseUrl: "https://#{Rails.env.production? ? 'www.salvamimaquina.com' : '0976-78-120-155-254.ngrok.io'}/checkout/three_d_secure_response"
            }
          }.to_json
        end

        # TODO: possibility to refacto this method used by this class and Authorize3ds class as well
        def signature(order_number, amount)
          Digest::SHA1.base64digest("#{FirstAtlanticCommerce::Base::PASSWORD}#{FirstAtlanticCommerce::Base::MERCHANT_ID}#{FirstAtlanticCommerce::Base::ACQUIRER_ID}#{order_number}#{amount}#{FirstAtlanticCommerce::Base::PURCHASE_CURRENCY}")
        end
      end
    end
  end
end
