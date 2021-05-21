# frozen_string_literal: true

module PaymentGateway
  class FirstAtlanticCommerce::Tokenize < FirstAtlanticCommerce::Base
    class << self
      def call(card_number:, customer_reference:, expiry_date:)
        binding.pry
        tokenize(xml_template(card_number, customer_reference, expiry_date))
        binding.pry
      end

      def xml_template(card_number, customer_reference, expiry_date)
        "<TokenizeRequest xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"http://schemas.firstatlanticcommerce.com/gateway/data\">
          <CardNumber>#{card_number}</CardNumber>
          <CustomerReference>#{customer_reference}</CustomerReference>
          <ExpiryDate>#{expiry_date}</ExpiryDate>
          <MerchantNumber>#{FirstAtlanticCommerce::Base::MERCHANT_ID}</MerchantNumber>
          <Signature>#{signature}</Signature>
        </TokenizeRequest>"
      end

      def signature
        Digest::SHA1.base64digest("#{FirstAtlanticCommerce::Base::PASSWORD}#{FirstAtlanticCommerce::Base::MERCHANT_ID}#{FirstAtlanticCommerce::Base::ACQUIRER_ID}")
      end
    end
  end
end