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

        if option_value.option_type.name == 'color'
          value = I18n.t("spree.colors.#{option_value.name}", default: nil) || option_value.presentation.capitalize
        else
          value = ApplicationController.helpers.branded_name(option_value.presentation) # TODO: not good to use helper in module like that...
        end

        type = I18n.t("spree.#{option_value.option_type.name}", count: 1, default: nil) || option_value.option_type.presentation.capitalize
        show_option_type ? "#{type}: #{value}" : value
      end.compact.join(', ')
    end

    Spree::Variant.prepend self
  end
end
