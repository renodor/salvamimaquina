# frozen_string_literal: true

# Custom shipping cost calculator that add a cost to the first package only
# All other packages will have a shipping cost of zero
# (Like that, even when order are splitted into 2 packages because some items are in Stock location 1 and other in Stock location 2,
# the shipping cost will always be the same, and won't be applied twice)
module Spree
  module Calculator::Shipping
    class CustomShippingCalculator < ShippingCalculator
      preference :amount, :decimal, default: 0

      def self.description
        'Custom Shipping Calculator (First package at amount, other packages free)'
      end

      def compute_package(package)
        if package.package_index&.zero?
          preferred_amount
        else
          0
        end
      end
    end
  end
end
