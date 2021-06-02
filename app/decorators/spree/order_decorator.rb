# frozen_string_literal: true

module Spree
  module OrderDecorator
    def self.prepended(base)
      base.remove_checkout_step :confirm
      base.insert_checkout_step :three_d_secure, { after: :payment }
    end

    Spree::Order.prepend self
  end
end
