# frozen_string_literal: true

module Spree
  module ProductFiltersHelper
    def price_range_slider
      {
        min: '10',
        max: '100'
      }
    end

    def product_filters
      products = @taxon&.products || Spree::Product.all

      return [] unless products.any?

      [price_range(products)]
    end

    def price_range(products)
      products_ordered_by_price = products.ascend_by_master_price
      highest_price = products_ordered_by_price.last.price.ceil
      lowest_price = products_ordered_by_price.first.price.floor

      interval = (highest_price - lowest_price) / 5

      range1 = [lowest_price, lowest_price + interval]
      range2 = [range1[1], range1[1] + interval]
      range3 = [range2[1], range2[1] + interval]
      range4 = [range3[1], range3[1] + interval]
      range5 = [range4[1], highest_price]

      {
        labels: [
          ["#{format_price(range1[0])} - #{format_price(range1[1])}", "#{range1[0]} - #{range1[1]}"],
          ["#{format_price(range2[0])} - #{format_price(range2[1])}", "#{range2[0]} - #{range2[1]}"],
          ["#{format_price(range3[0])} - #{format_price(range3[1])}", "#{range3[0]} - #{range3[1]}"],
          ["#{format_price(range4[0])} - #{format_price(range4[1])}", "#{range4[0]} - #{range4[1]}"],
          ["#{format_price(range5[0])} - #{format_price(range5[1])}", "#{range5[0]} - #{range5[1]}"]
        ],
        name: I18n.t('spree.price_range'),
        scope: :price_between
      }
    end

    def format_price(amount)
      Spree::Money.new(amount)
    end
  end
end
