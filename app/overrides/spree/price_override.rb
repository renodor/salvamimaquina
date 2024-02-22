# frozen_string_literal: true

module Spree
  module PriceOverride
    def self.prepended(base)
      base.has_many :active_sale_prices, -> { active }, class_name: 'SalePrice'
    end

    # # Redecorate Solidus Sales Price gem methods (https://github.com/solidusio-contrib/solidus_sale_prices)
    # # to use :active_sale_prices relation in order to be able to includes it in ActiveRecord queries and thus avoid N+1
    def price
      active_sale_prices.first&.value || self[:amount]
    end

    Spree::Price.prepend self
  end
end
