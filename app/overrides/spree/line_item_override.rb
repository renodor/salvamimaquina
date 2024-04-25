# frozen_string_literal:true

module Spree
  module LineItemOverride
    # Simplify Spree::Variant#can_supply method has we don't need all built in solidus options
    def sufficient_stock?
      variant.can_supply? quantity
    end

    Spree::LineItem.prepend self
  end
end
