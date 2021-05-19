module PaymentGateway
  module FirstAtlanticCommerce
    class Authorize
      ACQUIRER_ID = Rails.application.credentials.fac_acquirer_id
      MERCHANT_ID = Rails.application.credentials.fac_merchant_id
      PASSWORD = Rails.application.credentials.fac_password
      PURCHASE_CURRENCY = 840 # FAC code for USD

      def self.call(amount)

        binding.pry
      end

      def generate_signature(order_id, amount)
        "#{PASSWORD}#{MERCHANT_ID}#{ACQUIRER_ID}#{order_id}#{amount}#{PURCHASE_CURRENCY}"
      end
    end
  end
end