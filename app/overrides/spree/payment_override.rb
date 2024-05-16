# frozen_string_literal: true

module Spree
  module PaymentOverride
    def self.prepended(base)
      base.before_create :generate_uuid
    end

    # Called directly from CheckoutsController after payment information is entered
    # Will trigger 3Dsecure
    def sale!(cc_info)
      return unless check_payment_preconditions!

      protect_from_connection_error do
        response = payment_method.sale(
          money.money.cents,
          cc_info,
          gateway_options
        )

        if response.success?
          self.response_code = response.params['iso_response_code']
          save

          response.params['html_form'] if response.params['html_form'].present?
        else
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
      end
    end

    def process_3ds_response(response)
      handled_3ds_response = payment_method.handle_3ds_response(response)
      handle_response(handled_3ds_response)
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
        failure
        SendMessageToSentry.send(
          payment_method.type,
          {
            payment_gateway_iso_response_code: response.params['iso_response_code'],
            payment_gateway_3ds_status: response.params['three_ds_status'],
            payment_gateway_error_message: response.message,
            payment_gateway_method_name: response.params['method_name'],
            order_number: order.number,
            errors: response.params['errors'],
            payment: as_json
          }
        )
        gateway_error(response)
        return false
      end

      self.response_code = response.params['iso_response_code']
      self.spi_token     = response.params['spi_token'] if response.params['spi_token']
      save

      true
    end

    Spree::Payment.prepend self
  end
end
