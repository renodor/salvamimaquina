# frozen_string_literal: true

# We override the #build_shipments method to assign a package_index to every packages of our orders
module Spree
  module Stock
    module SimpleCoordinatorOverride
      private

      def build_shipments
        # Turn the Stock::Packages into a Shipment with rates
        packages.each_with_index.map do |package, index|
          package.package_index = index
          shipment = package.shipment = package.to_shipment
          shipment.shipping_rates = Spree::Config.stock.estimator_class.new.shipping_rates(package)
          shipment
        end
      end

      Spree::Stock::SimpleCoordinator.prepend self
    end
  end
end
