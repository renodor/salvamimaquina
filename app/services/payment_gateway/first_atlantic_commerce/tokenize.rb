# frozen_string_literal: true

module PaymentGateway
  module FirstAtlanticCommerce
    class Tokenize < FirstAtlanticCommerce::Base
      def initialize(card_number, customer_reference, expiry_date)
        @card_number = card_number
        @customer_reference = customer_reference
        @expiry_date = expiry_date
        @token = nil
        @success = false
      end

      def call
        xml_response = tokenize(xml_template)
        xml_parsed_response = Nokogiri::XML(xml_response).remove_namespaces!

        if xml_parsed_response.xpath('//Success').text == 'true'
          @success = true
          @token = xml_parsed_response.xpath('//Token').text
        else
          @success = false
        end
      end

      def xml_template
        "<TokenizeRequest xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"http://schemas.firstatlanticcommerce.com/gateway/data\">
          <CardNumber>#{@card_number}</CardNumber>
          <CustomerReference>#{@customer_reference}</CustomerReference>
          <ExpiryDate>#{@expiry_date}</ExpiryDate>
          <MerchantNumber>#{FirstAtlanticCommerce::Base::MERCHANT_ID}</MerchantNumber>
          <Signature>#{signature}</Signature>
        </TokenizeRequest>"
      end

      def signature
        Digest::SHA1.base64digest("#{FirstAtlanticCommerce::Base::PASSWORD}#{FirstAtlanticCommerce::Base::MERCHANT_ID}#{FirstAtlanticCommerce::Base::ACQUIRER_ID}")
      end

      def success?
        @success
      end
    end
  end
end