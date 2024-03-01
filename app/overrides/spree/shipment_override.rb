# frozen_string_literal:true

module Spree
  module ShipmentOverride

    # Remove unnecessary .includes(variant: :product)
    def to_package
      package = Stock::Package.new(stock_location)
      package.shipment = self
      inventory_units.includes(:variant).joins(:variant).group_by(&:state).each do |state, state_inventory_units|
        package.add_multiple state_inventory_units, state.to_sym
      end
      package
    end

    Spree::Shipment.prepend self
  end
end
