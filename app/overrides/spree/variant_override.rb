# frozen_string_literal: true

module Spree
  module VariantOverride
    extend ActiveSupport::Concern

    prepended do
      validates :repair_shopr_id, uniqueness: { conditions: -> { where(deleted_at: nil) } }, allow_nil: true
      enum condition: { original: 0, refurbished: 1 }
    end

    class_methods do
      # Returns the Spree::OptionValue (only the id and option_type_id) of the given variant_ids, grouped by option_type_id. Ex:
      # {
      #   56: [
      #     { id: 382, option_type_id: 56 }
      #   ]
      #   57: [
      #     { id: 375, option_type_id: 57 },
      #     { id: 377, option_type_id: 57 }
      #   ]
      # }
      # where the keys 56 and 57 are Spree::OptionType ids
      # and the values (ex: {id: 382, option_type_id: 56}) contain Spree::OptionValue id and Spree::OptionValue option_type_id
      def option_values_by_option_type(variant_ids)
        option_value_scope = Spree::OptionValuesVariant.joins(:variant).where(spree_variants: { id: variant_ids })
        option_value_ids = option_value_scope.distinct.pluck(:option_value_id)
        Spree::OptionValue.where(id: option_value_ids)
                          .select(:id, :option_type_id)
                          .group_by(&:option_type_id)
      end
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

    # # Simplify price methods to avoid using Spree::DefaultPrice module
    # # (We don't need it has our store only has 1 currency, and variants can only have one price)
    def price
      prices.order(created_at: :desc)&.take&.price
    end

    def price=(amount)
      price_record = prices.order(created_at: :desc)&.take || prices.new(currency: 'USD')
      price_record.price = amount
      price_record.save unless new_record? # For new variants price will be persisted when variant is saved

      price_record.amount
    end

    # Redecorate Solidus Sales Price gem methods (https://github.com/solidusio-contrib/solidus_sale_prices)
    # to use :active_sale_prices relation in order to be able to includes it in ActiveRecord queries and thus avoid N+1
    # and to avoid using Spree::DefaultPrice module
    def on_sale?
      prices.order(created_at: :desc)&.take&.active_sale_prices.present?
    end

    def original_price
      prices.order(created_at: :desc)&.take&.original_price
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
