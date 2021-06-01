# frozen_string_literal: true

module Spree
  module ProcessingDecorator
    def process!
      puts "blablabla"
    end

    def authorize!
      binding.pry
      handle_payment_preconditions { process_authorization }
    end

    def purchase!
      binding.pry
      handle_payment_preconditions { process_purchase }
    end

    def gateway_action(source, action, success_state)
      protect_from_connection_error do
        response = payment_method.send(action, money.money.cents,
                                        source,
                                        gateway_options)

        binding.pry
        handle_response(response, success_state, :failure)
      end
    end

    Spree::Payment::Processing.prepend self
  end
end