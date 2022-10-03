# frozen_string_literal: true

module Spree
  module PaymentDecorator
    def self.prepended(base)
      base.before_create :generate_uuid
    end

    # TODO: those authorize methods should be called directly by the "process_payments_before_complete" method inside Order model,
    # Instead of being called directly... So that the whole native solidus payment flow is not altered
    # (But not sure it is possible without having to tokenize credit cards)
    def authorize(cc_info)
      handle_payment_preconditions { gateway_action(cc_info, :authorize, nil) }
    end

    def authorize_3ds(cc_info)
      handle_payment_preconditions { gateway_action(cc_info, :authorize_3ds, nil) }
    end

    def process_3ds_response(response)
      response = payment_method.handle_3ds_response(response)
      handle_response(response, nil, :failure)
    end

    private

    def generate_uuid
      self.uuid = SecureRandom.uuid
    end

    def handle_response(response, success_state, failure_state)
      record_response(response) unless response.params['type'] == :authorize_3ds_response

      if response.success?
        unless response.authorization.nil?
          self.response_code = response.authorization
          self.avs_response = response.avs_result['code']

          if response.cvv_result
            self.cvv_response_code = response.cvv_result['code']
            self.cvv_response_message = response.cvv_result['message']
          end
        end

        # Authorize3dsResponse returns an html form that needs to be displayed to the browser for the user to complete
        # So instead of sending payment to next state we need to return this form so that the checkout controller can sends it to the view
        if response.params['type'] == :authorize_3ds_response
          response.params['html_form']
        elsif !success_state
          # In order to avoid storing credit card info, and thus tokenize credit card,
          # we process payment directly with front end params, right after user give its credit card infos.
          # But by doing so we are messing with normal payment state machine,
          # So authorize_3ds and process_3ds_response methods steps are like "out of" payment state machine, and are like pre-processing steps
          # So when calling this handle_response method, we do so without a success_state
          # In that case, if response is successfull, just return true and don't send payment to a new state
          true
        else
          send("#{success_state}!")
        end
      else
        Sentry.capture_message(
          payment_method.type,
          {
            extra: {
              payment_gateway_error: response.message,
              payment_gateway_response_code: response.authorization,
              payment_gateway_reason_code: response.params['reason_code'],
              payment_number: number,
              order_number: order.number,
              method_name: response.params['method_name']
            }
          }
        )
        send(failure_state)
        gateway_error(response)
      end
    end

    Spree::Payment.prepend self
  end
end
