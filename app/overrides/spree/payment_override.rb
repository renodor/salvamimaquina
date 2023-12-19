# frozen_string_literal: true

module Spree
  module PaymentOverride
    def self.prepended(base)
      base.before_create :generate_uuid
    end

    # TODO: methods should be called by the "process_payments_before_complete" method inside Order model,
    # Instead of being called directly... So that the whole native solidus payment flow is not altered
    # (But not sure it is possible without having to tokenize credit cards)
    def sale(cc_info)
      return unless check_payment_preconditions!

      protect_from_connection_error do
        response = payment_method.sale(
          money.money.cents,
          cc_info,
          gateway_options
        )
        # pend! if handle_response(response)

        handle_response(response)
      end
    end

    def process_3ds_response(response)
      handled_3ds_response = payment_method.handle_3ds_response(response)
      handle_response(handled_3ds_response, nil, :failure)
    end

    private

    def generate_uuid
      self.uuid = SecureRandom.uuid
    end

    # @returns true if the response is successful
    # @returns false (and calls #failure) if the response is not successful
    def handle_response(response)
      record_response(response)

      unless response.success?
        binding.pry
        failure
        SendMessageToSentry.send(
          payment_method.type,
          {
            payment_gateway_iso_response_code: response.params['iso_response_code'],
            payment_gateway_3ds_status: response.params['three_ds_status'],
            payment_gateway_error_message: response.message,
            payment_gateway_method_name: response.params['method_name'],
            order_number: order.number,
            payment: as_json
          }
        )
        gateway_error(response)
        return false
      end

      self.response_code = response.params['iso_response_code']
      self.spi_token     = response.params['spi_token'] if response.params['spi_token']
      save

      # "sale" method returns an html form that needs to be displayed to the browser for the user to fill it
      # So if this html form is present, instead of sending payment to next state,
      # we return this html form so that the checkout controller can sends it to the view
      response.params['html_form'] if response.params['method_name'] == 'Sale' && response.params['html_form'].present?

      true
    end

    Spree::Payment.prepend self
  end
end
