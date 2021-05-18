# frozen_string_literal: true

module SolidusPaypalBraintree
  class Gateway
    def initialize(option)
      # Get the pref set on admin
      Spree::PaymentMethod::BacCreditCard.configure do |config|
        config.fac_merchant_id = option[:fac_merchant_id]
      end
    end

    def authorize(money, source, option = {})
      binding.pry
    end

    def capture(money, transaction_id, options = {})
      binding.pry
    end

    # = authorize AND capture at once
    def purchase(money, source, options = {})
      binding.pry
    end

    def void(transaction_id, money, options = {})
    end

    def credit(money, transaction_id, options = {})
    end

    def try_void(payment)
    end
  end
end