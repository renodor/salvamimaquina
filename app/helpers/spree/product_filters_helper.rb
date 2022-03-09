# frozen_string_literal: true

module Spree
  module ProductFiltersHelper
    COLORS = {
      rojo: '#BB0B2D',
      azul: '#41A9E1',
      silver: '#E9E9E9',
      negro: '#000000',
      blanco: '#FCFBFE',
      amarillo: '#F6D04A',
      naranja: '#ff9c23',
      verde: '#98E164',
      morado: '#d99fea',
      rosado: '#EFC4C0',
      gris: '#adadad',
      marron: '#683E2C',
      gold: '#fff190',
      beige: '#DBC5A4',
      turquesa: '#5FDAE2',
      coral: '#F65F45',
      mallow: '#D3CFDC',
      space_gray: '#4e575a',
      grafito: '#323535',
      verde_noche: '#366644',
      negro_mate: '#3b3b3b',
      sierra_blue: '#95AFC8'
    }.freeze

    def build_price_range_slider_values
      variant_ids = @taxon&.all_variants&.pluck(:id)

      return nil unless variant_ids.present?

      prices = Spree::Price.includes(:active_sale_prices).where(variant_id: variant_ids).sort_by(&:price)

      lowest_price = prices[0].price.floor
      highest_price = prices[-1].price.ceil

      return nil if lowest_price == highest_price

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

    def checkbox_product_filter(option_type)
      variants = @taxon&.all_variants&.includes(:option_values) || Spree::Variant.where(product: @products).includes(:option_values)

      return nil unless variants

      option_type_id = Spree::OptionType.find_by(name: option_type).id

      variant_options = {}
      variants.each do |variant|
        option_value = variant.option_values.detect { |ov| ov.option_type_id == option_type_id }
        variant_options[option_value.name] = option_value.id if option_value.present?
      end

      variant_options
    end

    def color_code(color)
      COLORS[color.downcase.tr(' ', '_').to_sym]
    end
  end
end
