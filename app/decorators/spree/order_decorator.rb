# frozen_string_literal: true

module Spree
  module OrderDecorator
    def self.prepended(base)
      base.remove_checkout_step :confirm
    end

    def process_payments_before_complete
      return unless payment_required?

      # In Solidus base code when payment failed order need to be send from "confirm" to "payment" state again
      # But before doing it, order errors need to be saved and then reassigned otherwise it will be lost
      # Here payment is our last order step, so if payment fail, order is already on "payment" step,
      # But Solidus codebase will still reassign order errors, resulting in actually assign all errors twice,
      # So the purpose of this decorator is just to simplify this method and prevent order errors to be reassigned twice
      process_payments! ? true : false
    end

    # Includes relations to avoid N+1
    def insufficient_stock_lines
      line_items.includes(variant: :stock_items).select(&:insufficient_stock?)
    end

    Spree::Order.prepend self
  end
end
