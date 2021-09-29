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
    # - translate option type and option value if possible
    # - use branded_name for option_value
    def options_text(show_option_type: false, show_model: false)
      option_values.includes(:option_type).order(:option_type_id).map do |option_value|
        next if option_value.option_type.name == 'model' && show_model == false

        value = if option_value.option_type.name == 'color'
                  I18n.t("spree.colors.#{option_value.name}", default: nil) || option_value.presentation.capitalize
                else
                  ApplicationController.helpers.branded_name(option_value.presentation) # TODO: not good to use helper in module like that...
                end

        type = I18n.t("spree.#{option_value.option_type.name}", count: 1, default: nil) || option_value.option_type.presentation.capitalize
        show_option_type ? "#{type}: #{value}" : value
      end.compact.join(', ')
    end

    # Simplify price method to avoid using Spree::DefaultPrice module
    # (We don't need it has our store only has 1 currency, and variants can only have one price)
    def price
      prices.take.price
    end

    # Redecorate Solidus Sales Price gem methods (https://github.com/solidusio-contrib/solidus_sale_prices)
    # to use :active_sale_prices relation in order to be able to includes it in ActiveRecord queries and thus avoid N+1
    # and to avoid using Spree::DefaultPrice module
    def on_sale?
      prices.take.active_sale_prices.present?
    end

    def original_price
      prices.take.original_price
    end

    Spree::Variant.prepend self
  end
end
