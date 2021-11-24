# frozen_string_literal: true

module PaymentGateway
  module FirstAtlanticCommerce
    class Authorize3ds < FirstAtlanticCommerce::Base
      class << self
        def call(amount:, card_info:, order_number:, email:, billing_address:)
          xml_response = authorize_3ds(xml_payload(amount, card_info, order_number, email, billing_address))
          xml_parsed_response = Nokogiri::XML(xml_response).remove_namespaces!

          {
            success: xml_parsed_response.xpath('//ResponseCode').text == '0',
            message: xml_parsed_response.xpath('//ResponseCodeDescription').text,
            html_form: Rails.env.production? ? xml_parsed_response.xpath('//HTMLFormData').text : test_mode_3ds_response_html_form(order_number)
          }
        end

        private

        def xml_payload(amount, card_info, order_number, email, billing_address)
          "<Authorize3DSRequest xmlns:i=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"http://schemas.firstatlanticcommerce.com/gateway/data\">
            <CardDetails>
              <CardCVV2>#{card_info[:card_cvv]}</CardCVV2>
              <CardExpiryDate>#{card_info[:card_expiry_date]}</CardExpiryDate>
              <CardNumber>#{card_info[:card_number]}</CardNumber>
              <Installments>0</Installments>
            </CardDetails>
            <MerchantResponseURL>https://#{Rails.env.production? ? 'www.salvamimaquina.com' : '78f52a6629e1.ngrok.io'}/checkout/three_d_secure_response</MerchantResponseURL>
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
          </Authorize3DSRequest>"
        end

        # # If using a Tokenized Card Number, CardExpiryDate can be any future date
        # # It does not have to match actual card expiry date, but must not be blank or past.
        # def date_in_one_year
        #   (Date.today + 365).strftime('%m%y')
        # end

        def signature(order_number, amount)
          Digest::SHA1.base64digest("#{FirstAtlanticCommerce::Base::PASSWORD}#{FirstAtlanticCommerce::Base::MERCHANT_ID}#{FirstAtlanticCommerce::Base::ACQUIRER_ID}#{order_number}#{amount}#{FirstAtlanticCommerce::Base::PURCHASE_CURRENCY}")
        end

        def test_mode_3ds_response_html_form(order_number)
          "<form action=\"/checkout/three_d_secure_response\" method=\"post\" data-remote=\"true\">
            <p>Simulate 3DS Authorization</p>
            <input type=\"radio\" id=\"success\" name=\"ResponseCode\" value=\"1\">
            <label for=\"success\">Success (Payment will eventually fail anyway because capture won't be successful without real 3ds...)</label><br>
            <input type=\"radio\" id=\"failure\" name=\"ResponseCode\" value=\"0\">
            <label for=\"failure\">Failure</label><br>
            <input type=\"hidden\" name=\"OrderID\" value=\"#{order_number.split('-').last}\">
            <input type=\"submit\" name=\"title\">
          </form>"
        end
      end
    end
  end
end
