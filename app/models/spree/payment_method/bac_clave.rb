# frozen_string_literal: true

module Spree
  class PaymentMethod::BacClave < Spree::PaymentMethod::CreditCard
    def gateway_class
      self.class
    end

    # def authorize(amount, source, options)
    # end

    # def authorize_3ds(amount, source, options)
    # end

    # def handle_3ds_response(response)
    # end

    # def capture(amount, order_number)
    # end

    def purchase(amount, _source, options = {})
      capture(amount, options[:order_id])
    end
  end
end
