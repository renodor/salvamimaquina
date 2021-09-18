# frozen_string_literal: true

module Spree
  module ProductFiltersHelper
    COLORS = {
      red: '#BB0B2D',
      blue: '#41A9E1',
      silver: '#E9E9E9',
      black: '#000000',
      white: '#FCFBFE',
      yellow: '#F6D04A',
      orange: '#ff9c23',
      green: '#98E164',
      purple: '#d99fea',
      pink: '#EFC4C0',
      gray: '#adadad',
      brown: '#683E2C',
      golden: '#fff190',
      beige: '#DBC5A4',
      turquoise: '#5FDAE2',
      coral: '#F65F45',
      mallow: '#D3CFDC',
      space_gray: '#4e575a',
      graphite: '#323535'
    }

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

    def model_filter
      products = @taxon&.all_products.presence

      return nil unless products

      models = {}
      products.each do |product|
        option_values = product.variant_option_values_by_option_type[model_option_type]
        option_values&.each { |option_value| models[option_value.name] = option_value.id }
      end

      models
    end

    def color_filter
      products = @taxon&.all_products.presence

      return nil unless products

      colors = {}
      products.each do |product|
        option_values = product.variant_option_values_by_option_type[color_option_type]
        option_values&.each { |option_value| colors[option_value.name] = option_value.id }
      end

      colors
    end

    def model_option_type
      Spree::OptionType.find_by(name: 'model') # TODO: cache that...
    end

    def color_option_type
      Spree::OptionType.find_by(name: 'color') # TODO: cache that...
    end

    def color_code(color)
      COLORS[color.to_sym]
    end
  end
end
