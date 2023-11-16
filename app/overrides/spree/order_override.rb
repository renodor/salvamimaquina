# frozen_string_literal: true

module Spree
  module OrderOverride
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

    def related_products
      # TODO: improve this SQL query...
      Spree::Product
        .not_deleted
        .where.not(id: products.pluck(:id))
        .where(id: Spree::Relation.where(related_to: products.pluck(:id)).pluck(:relatable_id))
        .includes(variants_including_master: [{ images: [attachment_attachment: :blob] }, { prices: :active_sale_prices }])
    end

    # Return the stock location that has more line items quantity
    # If both locations have the same line item quantities, return Bella Vista
    def define_stock_location
      quantity_by_stock_location = Hash.new(0)
      shipments.each do |shipment|
        quantity_by_stock_location[shipment.stock_location.id] += shipment.line_items.map(&:quantity).sum
      end

      return Spree::StockLocation.find_by(name: 'Bella Vista') if quantity_by_stock_location.values.uniq == 1

      max_quantity_stock_location_id = quantity_by_stock_location.max_by { |_, qty| qty }[0]
      Spree::StockLocation.find(max_quantity_stock_location_id)
    end

    Spree::Order.prepend self
  end
end
