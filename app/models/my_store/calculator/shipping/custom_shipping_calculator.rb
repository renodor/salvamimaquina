module MyStore
  class Calculator::Shipping::CustomShippingCalculator < Spree::ShippingCalculator
    preference :first_item,      :decimal, default: 0.0
    preference :additional_item, :decimal, default: 0.0

    def self.description
      "Custom Shipping Calculator"
    end

    def compute_package(package)
      binding.pry
      12
    end
  end
end