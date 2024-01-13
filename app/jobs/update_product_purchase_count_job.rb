# frozen_string_literal: true

class UpdateProductPurchaseCountJob < ApplicationJob
  queue_as :default

  def perform(order)
    order.line_items.each do |line_item|
      product = line_item.product
      product.purchase_count += line_item.quantity
      product.save!
    end
  end
end
