# frozen_string_literal: true

module Spree
  module PaymentDecorator
    def self.prepended(base)
      base.before_create :generate_uuid
    end

    # TODO: methods should be called by the "process_payments_before_complete" method inside Order model,
    # Instead of being called directly... So that the whole native solidus payment flow is not altered
    # (But not sure it is possible without having to tokenize credit cards)
    def sale(cc_info)
      handle_payment_preconditions { gateway_action(cc_info, :sale, nil) }
    end

    def process_3ds_response(response)
      handled_3ds_response = payment_method.handle_3ds_response(response)
      handle_response(handled_3ds_response, nil, :failure)
    end

    private

    def generate_uuid
      self.uuid = SecureRandom.uuid
    end

    def handle_response(response, success_state, failure_state)
      record_response(response)
      if response.success?
        self.response_code = response.params['iso_response_code']
        self.spi_token     = response.params['spi_token'] if response.params['spi_token']
        save

        # "sale" method returns an html form that needs to be displayed to the browser for the user to fill it
        # So instead of sending payment to next state we need to return this form so that the checkout controller can sends it to the view
        response.params['html_form'] || send("#{success_state}!")
      else
        Sentry.capture_message(
          payment_method.type,
          {
            extra: {
              payment_gateway_error: response.message,
              payment_gateway_response_code: response.params['response_code'],
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
