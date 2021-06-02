# frozen_string_literal: true

module Spree
  module OrderDecorator
    def self.prepended(base)
      # base.insert_checkout_step :three_d_secure, { after: :payment }
      base.remove_checkout_step :confirm
    end

    def three_d_secure
      binding.pry
    end

    Spree::Order.prepend self
  end
end
