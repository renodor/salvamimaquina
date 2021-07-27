# frozen_string_literal: true

module Spree
  module PriceDecorator
    def self.prepended(base)
      base.before_save :equalize_master_price_for_products_with_variants
    end

    # In our current shop configuration, when product has variants, master price is never really used.
    # But if, for some reason, this master price is lower or higher than the price any of the other variants,
    # it can causes issue in the front end price range filter.
    # So whenever a variant price is changed, if this is the master variant of a product with variants,
    # we cancel this change and set the price equal to the price of another variant of the same product.
    def equalize_master_price_for_products_with_variants
      return unless variant.is_master? && variant.product.has_variants?

      # TODO: add visual explaination on front end when this happen
      self.amount = variant.product.variants.last.price
    end

    Spree::Price.prepend self
  end
end
