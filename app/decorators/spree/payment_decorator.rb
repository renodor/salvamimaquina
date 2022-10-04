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
        # So if this html form is present, instead of sending payment to next state,
        # we return this html form so that the checkout controller can sends it to the view
        if response.params['method_name'] == 'Sale' && response.params['html_form'].present?
          response.params['html_form']
        else
          send("#{success_state}!")
        end
      else
        Sentry.capture_message(
          payment_method.type,
          {
            extra: {
              payment_gateway_iso_response_code: response.params['iso_response_code'],
              payment_gateway_3ds_status: response.params['three_ds_status'],
              payment_gateway_error_message: response.message,
              payment_gateway_method_name: response.params['method_name'],
              order_number: order.number,
              payment: as_json
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
