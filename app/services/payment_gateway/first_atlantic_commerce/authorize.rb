# frozen_string_literal: true

module PaymentGateway
  module FirstAtlanticCommerce
    class Authorize < FirstAtlanticCommerce::Base
      class << self
        def call(amount:, card_number:, card_cvv:, card_expiry_date:, order_number:)
          xml_response = authorize(xml_payload(amount, card_number, card_cvv, card_expiry_date, order_number))
          xml_parsed_response = Nokogiri::XML(xml_response).remove_namespaces!
          response_code = xml_parsed_response.xpath('//ResponseCode').text

          {
            success: response_code == '1',
            message: xml_parsed_response.xpath('//ReasonCodeDescription').text,
            response_code: response_code
          }
        end

        private

        # TODO: possibility to refacto this payload (almost similar) used by this class and Authorize3ds class as well
        def xml_payload(amount, card_number, card_cvv, card_expiry_date, order_number)
          "<AuthorizeRequest xmlns:i=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"http://schemas.firstatlanticcommerce.com/gateway/data\">
            <CardDetails>
            <CardCVV2>#{card_cvv}</CardCVV2>
            <CardExpiryDate>#{card_expiry_date}</CardExpiryDate>
            <CardNumber>#{card_number}</CardNumber>
            <Installments>0</Installments>
            </CardDetails>
            <MerchantResponseURL>https://d4f3c036200e.ngrok.io/shop/checkout/three_d_secure_response</MerchantResponseURL>
            <TransactionDetails>
              <AcquirerId>#{FirstAtlanticCommerce::Base::ACQUIRER_ID}</AcquirerId>
              <Amount>#{amount}</Amount>
              <Currency>#{FirstAtlanticCommerce::Base::PURCHASE_CURRENCY}</Currency>
              <CurrencyExponent>2</CurrencyExponent>
              <MerchantId>#{FirstAtlanticCommerce::Base::MERCHANT_ID}</MerchantId>
              <OrderNumber>#{order_number}</OrderNumber>
              <Signature>#{signature(order_number, amount)}</Signature>
              <SignatureMethod>SHA1</SignatureMethod>
              <TransactionCode>0</TransactionCode>
              <CustomerReference>This is a test</CustomerReference>
            </TransactionDetails>
          </AuthorizeRequest>"
        end

        # TODO: possibility to refacto this method used by this class and Authorize3ds class as well
        def signature(order_number, amount)
          Digest::SHA1.base64digest("#{FirstAtlanticCommerce::Base::PASSWORD}#{FirstAtlanticCommerce::Base::MERCHANT_ID}#{FirstAtlanticCommerce::Base::ACQUIRER_ID}#{order_number}#{amount}#{FirstAtlanticCommerce::Base::PURCHASE_CURRENCY}")
        end
      end
    end
  end
end
