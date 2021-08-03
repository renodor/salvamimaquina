# frozen_string_literal: true

module Spree
  module ProductFiltersHelper
    def price_range_slider
      products = @taxon&.all_products.presence || Spree::Product.all

      return nil unless products.any?

      variants = []
      products.each { |product| variants += product.variants_including_master }
      variants_ordered_by_price = variants.sort_by(&:price)
      lowest_price = variants_ordered_by_price.first.price.floor
      highest_price = variants_ordered_by_price.last.price.ceil

      if params[:search] && params[:search][:price_between]
        parsed_prices = params[:search][:price_between].map(&:to_i)
        current_min = parsed_prices.min
        current_max = parsed_prices.max
      end

      {
        min: lowest_price,
        max: highest_price,
        current_min: current_min || lowest_price,
        current_max: current_max || highest_price
      }
    end
  end
end
