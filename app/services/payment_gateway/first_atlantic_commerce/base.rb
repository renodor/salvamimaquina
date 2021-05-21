# frozen_string_literal: true

module PaymentGateway
  class FirstAtlanticCommerce::Base
    BASE_URL = "https://#{Rails.env.production? ? 'marlin' : 'ecm'}.firstatlanticcommerce.com/PGServiceXML"
    ACQUIRER_ID = Rails.application.credentials.fac_acquirer_id
    MERCHANT_ID = Rails.application.credentials[Rails.env.production? ? :fac_merchant_id : :fac_merchant_id_test]
    PASSWORD = Rails.application.credentials[Rails.env.production? ? :fac_password : :fac_password_test]
    PURCHASE_CURRENCY = 840 # FAC code for USD

    class << self

      private

      def generate_signature(order_id, amount)
        "#{PASSWORD}#{MERCHANT_ID}#{ACQUIRER_ID}#{order_id}#{amount}#{PURCHASE_CURRENCY}"
      end

      def tokenize(xml_payload)
        binding.pry
        request(http_method: :post, endpoint: 'Tokenize', params: xml_payload)
        binding.pry
      end


      def client
        Faraday.new(BASE_URL) do |client|
          client.request :url_encoded
          client.adapter Faraday.default_adapter # The default adapter is :net_http
          client.headers['Content-Type'] = 'text/xml'
        end
      end

      def request(http_method:, endpoint:, params: {})
        @response = client.public_send(http_method, endpoint, params)
        parsed_response = Oj.load(@response.body)

        return parsed_response if @response.status == HTTP_OK_CODE

        raise error_class, "Code: #{@response.status}, response: #{@response.body}"
      end
    end
  end
end
