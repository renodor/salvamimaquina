# frozen_string_literal: true

module PaymentGateway
  module FirstAtlanticCommerce
    class Payment
      include Client

      def initialize(spi_token:)
        @spi_token = spi_token.to_json
      end

      def call
        response = request(http_method: :post, endpoint: 'payment', params: @spi_token)

        {
          success: response[:Approved],
          message: response[:ResponseMessage],
          iso_response_code: response[:IsoResponseCode]
        }
      end
    end
  end
end
