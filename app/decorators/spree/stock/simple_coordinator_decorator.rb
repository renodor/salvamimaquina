# frozen_string_literal: true

# We need to monkey patch the whole #build_shipments method in order to assigne a package_index to every packages of our orders
# The modification happend at line 34 and 35:
# - we add an index argument to the iteration
# - we assign a package_index to each package
module Spree
  module Stock
    module SimpleCoordinatorDecorator
      def build_shipments
        # Allocate any available on hand inventory and remaining desired inventory from backorders
        on_hand_packages, backordered_packages, leftover = @allocator.allocate_inventory(@desired)

        raise Spree::Order::InsufficientStock.new(items: leftover.quantities) unless leftover.empty?

        packages = @stock_locations.map do |stock_location|
          # Combine on_hand and backorders into a single package per-location
          on_hand = on_hand_packages[stock_location.id] || Spree::StockQuantities.new
          backordered = backordered_packages[stock_location.id] || Spree::StockQuantities.new

          # Skip this location it has no inventory
          next if on_hand.empty? && backordered.empty?

          # Turn our raw quantities into a Stock::Package
          package = Spree::Stock::Package.new(stock_location)
          package.add_multiple(get_units(on_hand), :on_hand)
          package.add_multiple(get_units(backordered), :backordered)

          package
        end.compact

        # Split the packages
        packages = split_packages(packages)

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
