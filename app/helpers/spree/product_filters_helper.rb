# frozen_string_literal: true

module Spree
  module ProductFiltersHelper
    def price_range_slider
      products = @taxon&.products || Spree::Product.all

      return [] unless products.any?

      products_ordered_by_price = products.ascend_by_master_price
      lowest_price = products_ordered_by_price.first.price.floor
      highest_price = products_ordered_by_price.last.price.ceil

      if params[:search] && params[:search][:price_between]
        current_min = params[:search][:price_between].min
        current_max = params[:search][:price_between].max
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
