# frozen_string_literal: true

module Spree
  module Stock
    module DifferentiatorDecorator
      private

      # Includes variant to avoid N+1 on checkout delivery page
      def build_required
        @required = Hash.new(0)
        order.line_items.includes(:variant).each do |line_item|
          @required[line_item.variant] = line_item.quantity
        end
      end

      Spree::Stock::Differentiator.prepend self
    end
  end
end
