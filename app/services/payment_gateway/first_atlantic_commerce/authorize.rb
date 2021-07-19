# frozen_string_literal: true

module PaymentGateway
  module FirstAtlanticCommerce
    class Authorize < FirstAtlanticCommerce::Base
      class << self
        def call(amount:, card_info:, order_number:, email:, billing_address:)
          xml_response = authorize(xml_payload(amount, card_info, order_number, email, billing_address))
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
        def xml_payload(amount, card_info, order_number, email, billing_address)
          "<AuthorizeRequest xmlns:i=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"http://schemas.firstatlanticcommerce.com/gateway/data\">
            <CardDetails>
              <CardCVV2>#{card_info[:card_cvv]}</CardCVV2>
              <CardExpiryDate>#{card_info[:card_expiry_date]}</CardExpiryDate>
              <CardNumber>#{card_info[:card_number]}</CardNumber>
              <Installments>0</Installments>
            </CardDetails>
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
            <BillingDetails>
              <BillToAddress>#{billing_address[:address1]}</BillToAddress>
              <BillToAddress2>#{billing_address[:address2]}</BillToAddress2>
              <BillToFirstName>#{billing_address[:name].split[0]}</BillToFirstName>
              <BillToLastName>#{billing_address[:name].split[1]}</BillToLastName>
              <BillToCity>#{billing_address[:city]}</BillToCity>
              <BillToCountry>591</BillToCountry>
              <BillToEmail>#{email}</BillToEmail>
              <BillToMobile>#{billing_address[:phone]}</BillToMobile>
            </BillingDetails>
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
