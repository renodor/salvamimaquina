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

    def translated_option_values(show_model: false)
      values = []
      option_values.order(:option_type_id).each do |option_value|
        next if option_value.option_type.name == 'model' && show_model == false

        values << I18n.t!("spree.#{option_value.option_type.name}.#{option_value.presentation}").capitalize
      rescue I18n::MissingTranslationData
        values << option_value.presentation.capitalize
      end

      values.join(' - ')
    end

    Spree::Variant.prepend self
  end
end
