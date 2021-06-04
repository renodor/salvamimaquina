# frozen_string_literal: true

module PaymentGateway
  module FirstAtlanticCommerce
    class Capture < FirstAtlanticCommerce::Base
      class << self
        def call(amount:, order_number:)
          xml_response = capture(xml_payload(amount, order_number))
          xml_parsed_response = Nokogiri::XML(xml_response).remove_namespaces!

          {
            success: xml_parsed_response.xpath('//ResponseCode').text == '1', # FAC success response code = 1, error response code = 3
            reason_code: xml_parsed_response.xpath('//ReasonCode').text,
            message: xml_parsed_response.xpath('//ReasonCodeDescription').text
          }
        end

        private

        def xml_payload(amount, order_number)
          "<TransactionModificationRequest xmlns:i=\"http://www.w3.org/2001/XMLSchemainstance\" xmlns=\"http://schemas.firstatlanticcommerce.com/gateway/data\">
            <AcquirerId>#{FirstAtlanticCommerce::Base::ACQUIRER_ID}</AcquirerId>
            <Amount>#{amount}</Amount>
            <CurrencyExponent>2</CurrencyExponent>
            <MerchantId>#{FirstAtlanticCommerce::Base::MERCHANT_ID}</MerchantId>
            <ModificationType>1</ModificationType>
            <OrderNumber>#{order_number}</OrderNumber>
            <Password>#{FirstAtlanticCommerce::Base::PASSWORD}</Password>
          </TransactionModificationRequest>"
        end
      end
    end
  end
end
