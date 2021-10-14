# frozen_string_literal: true

module Spree
  module VariantDecorator
    def self.prepended(base)
      base.validates :repair_shopr_id, uniqueness: true, allow_nil: true
      base.enum condition: { original: 0, refurbished: 1 }
    end

    def destroy_and_destroy_product_if_no_other_variants!
      product = self.product
      destroy!
      product.destroy! unless product.reload.has_variants?
    end

    # Modify Spree::Variant#options_text to be able to:
    # - show or not option type
    # - show or not model
    # - translate option type
    def options_text(show_option_type: false, show_model: false)
      option_values.map do |option_value|
        option_type = option_value.option_type
        next if option_type.name == 'model' && show_model == false

        value = option_value.presentation.capitalize
        type = I18n.t("spree.#{option_type.name}", count: 1, default: nil) || option_type.presentation.capitalize
        show_option_type ? "#{type}: #{value}" : value
      end.compact.join(', ')
    end

    # Simplify price method to avoid using Spree::DefaultPrice module
    # (We don't need it has our store only has 1 currency, and variants can only have one price)
    def price
      prices&.take&.price || initialize_price
    end

    def initialize_price
      price = Spree::Price.new(Spree::Config.default_pricing_options.desired_attributes)
      price.variant_id = id
      nil
    end

    # Redecorate Solidus Sales Price gem methods (https://github.com/solidusio-contrib/solidus_sale_prices)
    # to use :active_sale_prices relation in order to be able to includes it in ActiveRecord queries and thus avoid N+1
    # and to avoid using Spree::DefaultPrice module
    def on_sale?
      prices&.take&.active_sale_prices.present?
    end

    def original_price
      prices&.take&.original_price
    end

    # Simplify Spree::Variant#can_supply method has we don't need all built in solidus options
    # We chose to use ActiveRecord#pluck and then Array#sum instead of ActiveRecord#sum directly,
    # So that we can includes stock_items beforehand and thus avoiding N+1
    # Because even if we includes stock_items, doing an ActiveRecord#sum will call the database
    # (It is discutable if using ActiveRecord#sum would be more performant anyway even if it creates more DB calls...)
    def can_supply?(quantity = 1)
      stock_items.pluck(:count_on_hand).sum >= quantity
    end

    Spree::Variant.prepend self
  end
end
