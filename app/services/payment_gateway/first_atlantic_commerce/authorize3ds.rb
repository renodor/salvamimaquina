# frozen_string_literal: true

module PaymentGateway
  module FirstAtlanticCommerce
    class Authorize3ds < FirstAtlanticCommerce::Base
      include Authorize3dsXmlTemplate

      class << self
        def call(money, source, order_number)
          xml_payload = build_authorize3ds_xml_payload(
            acquirer_id: FirstAtlanticCommerce::Base::ACQUIRER_ID,
            merchant_id: FirstAtlanticCommerce::Base::MERCHANT_ID,
            order_number: order_number,
            amount: '000000001200',
            currency_code: FirstAtlanticCommerce::Base::PURCHASE_CURRENCY,
            signature: signature(order_number, '000000001200'),
            card_number: source[:token],
            card_expiry_date: "#{source[:month]}#{source[:year][2..-1]}",
            card_cvv: Base64.decode64(source[:encoded_cvv])
          )

          xml_response = authorize3ds(xml_payload)
          xml_parsed_response = Nokogiri::XML(xml_response).remove_namespaces!
          html_form = xml_parsed_response.xpath('//HTMLFormData').text

          {
            success: html_form.present?,
            html_form: html_form
          }
        end

        def signature(order_id, amount)
          Digest::SHA1.base64digest("#{FirstAtlanticCommerce::Base::PASSWORD}#{FirstAtlanticCommerce::Base::MERCHANT_ID}#{FirstAtlanticCommerce::Base::ACQUIRER_ID}#{order_id}#{amount}#{FirstAtlanticCommerce::Base::PURCHASE_CURRENCY}")
        end
      end
    end
  end
end