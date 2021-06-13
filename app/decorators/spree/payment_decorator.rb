# frozen_string_literal: true

module Spree
  module PaymentDecorator
    # def authorize_3ds(source)
    #   response = ThreeDSecure.authorize(order, source)
    #   if response.success?
    #     response.params['html_form']
    #   else
    #     # TODO: this needs to be handled directly by the Spree::Payment::Processing module...
    #     # TODO: add fac error message to payment
    #     update!(state: 'failed')
    #     update!(payment_state: 'failed')
    #     false
    #   end
    # end

    def authorize_3ds!
      handle_payment_preconditions { process_authorization_3ds }
    end

    private

    def process_authorization_3ds
      started_processing!
      gateway_action(source, :authorize_3ds, :pend)
    end

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

        # Authorize3dsResponse returns an html form that needs to be display to the browser for the user to complete
        if response.params['type'] == :authorize_3ds_response
          response.params['html_form']
        else
          send("#{success_state}!")
        end
      else
        send(failure_state)
        gateway_error(response)
      end
    end

    Spree::Payment.prepend self
  end
end
