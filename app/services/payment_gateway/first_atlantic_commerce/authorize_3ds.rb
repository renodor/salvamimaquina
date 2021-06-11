# frozen_string_literal: true

module PaymentGateway
  module FirstAtlanticCommerce
    class Authorize3ds < FirstAtlanticCommerce::Base
      class << self
        def call(amount:, card_number:, card_expiry_date:, card_cvv:, order_number:)
          xml_response = authorize_3ds(xml_payload(amount, card_number, card_expiry_date, card_cvv, order_number))
          xml_parsed_response = Nokogiri::XML(xml_response).remove_namespaces!

          {
            success: xml_parsed_response.xpath('//ResponseCode').text == '0',
            message: xml_parsed_response.xpath('//ResponseCodeDescription').text,
            html_form: xml_parsed_response.xpath('//HTMLFormData').text
          }
        end

        private

        def xml_payload(amount, card_number, card_expiry_date, card_cvv, order_number)
          "<Authorize3DSRequest xmlns:i=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"http://schemas.firstatlanticcommerce.com/gateway/data\">
            <CardDetails>
            <CardCVV2>#{card_cvv}</CardCVV2>
            <CardExpiryDate>#{card_expiry_date}</CardExpiryDate>
            <CardNumber>#{card_number}</CardNumber>
            <Installments>0</Installments>
            </CardDetails>
            <MerchantResponseURL>https://e05063d9d9b4.ngrok.io/shop/checkout/three_d_secure_response</MerchantResponseURL>
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
          </Authorize3DSRequest>"
        end

        def signature(order_number, amount)
          Digest::SHA1.base64digest("#{FirstAtlanticCommerce::Base::PASSWORD}#{FirstAtlanticCommerce::Base::MERCHANT_ID}#{FirstAtlanticCommerce::Base::ACQUIRER_ID}#{order_number}#{amount}#{FirstAtlanticCommerce::Base::PURCHASE_CURRENCY}")
        end
      end
    end
  end
end
