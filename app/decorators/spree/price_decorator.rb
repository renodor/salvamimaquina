# frozen_string_literal: true

module Spree
  module PriceDecorator
    def self.prepended(base)
      base.before_save :equalize_master_price_for_products_with_variants
      base.has_many :active_sale_prices, -> { active }, class_name: 'SalePrice'
    end

    # In our current shop configuration, when product has variants, master price is never really used.
    # But if, for some reason, this master price is lower or higher than the price of any other variants,
    # it can causes issue in the front end price range filter.
    # So whenever a variant price is changed, if this is the master variant of a product with variants,
    # we cancel this change and set the price equal to the price of another variant of the same product.
    def equalize_master_price_for_products_with_variants
      return unless variant&.is_master? && variant&.product&.has_variants?

      # TODO: add visual explaination on front end when this happen
      self.amount = variant.product.variants.last.price
    end

    # Redecorate Solidus Sales Price gem methods (https://github.com/solidusio-contrib/solidus_sale_prices)
    # to use :active_sale_prices relation in order to be able to includes it in ActiveRecord queries and thus avoid N+1
    def price
      active_sale_prices.present? ? active_sale_prices.first.value : self[:amount]
    end

    def amount
      price
    end

    Spree::Price.prepend self
  end
end
