# frozen_string_literal: true

module PaymentGateway
  module FirstAtlanticCommerce
    class Payment < FirstAtlanticCommerce::Base
      class << self
        def call(spi_token:)
          response = payment(spi_token.to_json)

          {
            success: response[:Approved],
            message: response[:ResponseMessage],
            reason_code: response[:IsoResponseCode]
          }
        end
      end
    end
  end
end
