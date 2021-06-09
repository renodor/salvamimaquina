# frozen_string_literal: true

module Spree
  module OrderDecorator
    def self.prepended(base)
      base.remove_checkout_step :confirm
    end

    Spree::Order.prepend self
  end
end
