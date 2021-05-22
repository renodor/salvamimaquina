# frozen_string_literal: true

module PaymentGateway
  module FirstAtlanticCommerce
    class Authorize < FirstAtlanticCommerce::Base
      include AuthorizeXmlTemplate

      class << self
        def call(money, source, options)
          binding.pry
          xml_payload = build_authorize_xml_payload(
            acquirer_id: FirstAtlanticCommerce::Base::ACQUIRER_ID,
            merchant_id: FirstAtlanticCommerce::Base::MERCHANT_ID,
            order_number: options[:order_id],
            amount: '000000001200',
            currency_code: FirstAtlanticCommerce::Base::PURCHASE_CURRENCY,
            signature: signature(options[:order_id], '000000001200'),
            card_number: '1111111111111111',
            card_expiry_date: '1123',
            card_cvv: '123'
          )

          authorize(xml_payload)
        end

        def signature(order_id, amount)
          Digest::SHA1.base64digest("#{FirstAtlanticCommerce::Base::PASSWORD}#{FirstAtlanticCommerce::Base::MERCHANT_ID}#{FirstAtlanticCommerce::Base::ACQUIRER_ID}#{order_id}#{amount}#{FirstAtlanticCommerce::Base::PURCHASE_CURRENCY}")
        end
      end
    end
  end
end