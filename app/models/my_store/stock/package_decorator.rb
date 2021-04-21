# frozen_string_literal: true

# Customize the package object so that it accepts an aditional "package_index" instance variable.
# package_index is defined when all the packages of a same order are created
# so the first package of the order will have package_index = 0,
# the second package_index = 1 etc...
# We use this information later to create a shipping cost calculator that will add a price only to the first package
module MyStore
  module Stock
    module PackageDecorator
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
