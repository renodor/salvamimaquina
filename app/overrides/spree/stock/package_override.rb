# frozen_string_literal: true

# Customize the package object so that it accepts an aditional "package_index" instance variable.
# package_index is defined when packages of an order are created
# so the first package of the order will have package_index = 0,
# the second package of the order will have package_index = 1 etc...
# We then use this information  to create a shipping cost calculator that will add a price only to the first package
module Spree
  module Stock
    module PackageOverride
      attr_accessor :shipment, :package_index

      def initialize(stock_location, contents = [], package_index = nil)
        @stock_location = stock_location
        @contents = contents
        @package_index = package_index
      end

      Spree::Stock::Package.prepend self
    end
  end
end
