# frozen_string_literal: true

module ProductFiltersHelper
  COLORS = {
    rojo: '#BB0B2D',
    red: '#BB0B2D',
    azul: '#41A9E1',
    blue: '#41A9E1',
    azul_oscuro: '#2f3c66',
    sierra_blue: '#95AFC8',
    blue_sierra: '#95AFC8',
    silver: '#E9E9E9',
    negro: '#000000',
    space_black: '#000000',
    black: '#000000',
    midnight: '#3C3C44',
    midnigth: '#3C3C44',
    white: '#FCFBFE',
    blanco: '#FCFBFE',
    blanco_estelar: '#FCFBFE',
    blanco_estrella: '#EAE3D9',
    starlight: '#D7CDC5',
    amarillo: '#F6D04A',
    naranja: '#ff9c23',
    verde: '#98E164',
    green: '#98E164',
    morado: '#d99fea',
    morando: '#d99fea',
    purple: '#d99fea',
    deep_purple: '#6F4F67',
    rosado: '#EFC4C0',
    rosa: '#EFC4C0',
    pink: '#EFC4C0',
    gris: '#adadad',
    marron: '#683E2C',
    gold: '#fff190',
    dorado: '#fff190',
    beige: '#DBC5A4',
    turquesa: '#5FDAE2',
    coral: '#F65F45',
    mallow: '#D3CFDC',
    space_gray: '#4e575a',
    space_grey: '#4e575a',
    grafito: '#323535',
    graphite: '#323535',
    verde_noche: '#366644',
    night_green: '#366644',
    alpine_green: '#366644',
    negro_mate: '#3b3b3b',
    matt_black: '#3b3b3b'
  }.freeze

  def build_price_range_slider_values
    products = @taxon&.all_products&.includes(:variants, :master) || @products.includes(:variants, :master)
    variants = products.flat_map { |product| product.variants.presence || product.master }
    variants.reject!(&:blank?)

    return nil unless variants.present?

    prices = Spree::Price.where(variant_id: variants.map(&:id)).sort_by(&:price)

    return nil unless prices.any?

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

    option_type_id = Spree::OptionType.find_by(name: option_type)&.id

    variant_options = {}
    variants.each do |variant|
      option_value = variant.option_values.detect { |ov| ov.option_type_id == option_type_id }
      variant_options[option_value.name] = option_value.id if option_value.present?
    end

    variant_options
  end

  def map_color_texts_to_hexa_color_codes(color_text_to_option_id)
    color_hexa_code_to_option_ids = Hash.new { |hash, key| hash[key] = [] }

    color_text_to_option_id.each do |color_text, id|
      color_hexa_code = color_hexa_code(color_text)
      color_hexa_code_to_option_ids[color_hexa_code] << id
    end

    color_hexa_code_to_option_ids
  end

  def color_hexa_code(color_text)
    COLORS[color_text.downcase.tr(' ', '_').to_sym]
  end
end
