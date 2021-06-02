# frozen_string_literal: true

module Spree
  module PaymentDecorator
    private

    def handle_response(response, success_state, failure_state)
      record_response(response)

      if response.success?
        unless response.authorization.nil?
          self.response_code = response.authorization
          self.avs_response = response.avs_result['code']

          if response.cvv_result
            self.cvv_response_code = response.cvv_result['code']
            self.cvv_response_message = response.cvv_result['message']
          end
        end
        send("#{success_state}!")
      else
        send(failure_state)
        gateway_error(response)
      end
    end

    Spree::Payment.prepend self
  end
end