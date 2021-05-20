# frozen_string_literal: true

module PaymentGateway
  class FirstAtlanticCommerce::Tokenize < FirstAtlanticCommerce::Base
    class << self
      def call(money, source, options)
        # money = 3299
        binding.pry
        # xml_payload = build_authorize_xml_payload(
        #   acquirer_id: ACQUIRER_ID,
        #   merchant_id: MERCHANT_ID,
        #   order_number:,
        #   amount:,
        #   currency_code:,
        #   signature:,
        #   card_number:,
        #   card_expiry_date:,
        #   card_cvv:
        # )
      end

      def generate_signature(order_id, amount)
        "#{PASSWORD}#{MERCHANT_ID}#{ACQUIRER_ID}#{order_id}#{amount}#{PURCHASE_CURRENCY}"
      end
    end
  end
end