# frozen_string_literal: true

module Spree
  module ProductDecorator
    extend ActiveSupport::Concern

    # rubocop:disable Metrics/BlockLength
    prepended do
      scope :ascend_by_purchase_count, -> { order(purchase_count: :asc) }
      scope :descend_by_purchase_count, -> { order(purchase_count: :desc) }
      scope :ascend_by_available_on, -> { order(available_on: :asc) }
      scope :descend_by_available_on, -> { order(available_on: :desc) }
      scope :on_sale, -> { joins(variants_including_master: { prices: :active_sale_prices }).distinct }
      add_search_scope :with_option do |option_type_id, option_value_id| # option_value_id can be one single id or an array of ids, it works the same
        joins(:option_types, variants_including_master: :option_values)
          .where(option_types: { id: option_type_id }, option_values: { id: option_value_id })
      end

      # Modify the solidus in_taxon scope to remove ordering and thus greatly simplify its SQL
      add_search_scope :in_taxon do |taxon|
        joins(:taxons).where('spree_taxons' => { id: taxon.self_and_descendants.pluck(:id) })
      end

      # TODO: simplify that using active_sale_prices scope? or recreating an intermediate model like "DefaultPrice" which always return the current price of a product/variant
      # Do TDD to test every possibility (product with and without variants, on sale and not on sale etc...), and then simplify
      add_search_scope :price_between do |min, max|
        min, max = max, min if min.to_i > max.to_i

        current_time = Time.now

        is_on_sale = '(spree_sale_prices.start_at <= ? OR spree_sale_prices.start_at IS NULL) AND (spree_sale_prices.end_at >= ? OR spree_sale_prices.end_at IS NULL)'
        is_not_on_sale = '((spree_sale_prices.id IS NULL) OR ((spree_sale_prices.start_at >= ?) OR (spree_sale_prices.end_at <= ?)))'

        left_outer_joins(:variants, :prices, :sale_prices)
          .distinct
          .where(
            "(#{is_on_sale} AND (spree_sale_prices.value BETWEEN ? AND ?))
            OR
            (#{is_not_on_sale} AND (spree_prices.amount BETWEEN ? AND ?))",
            current_time, current_time, min, max, current_time, current_time, min, max
          )
      end
    end
    # rubocop:enable Metrics/BlockLength

    class_methods do
      # Keys are the scope or the method of the sorting option,
      # values are the i18n key to get the translated name of the sorting option
      def sorting_options
        {
          descend_by_available_on: :newest,
          ascend_by_available_on: :oldest,
          ascend_by_price: :ascend_by_price,
          descend_by_price: :descend_by_price,
          descend_by_purchase_count: :best_seller
        }
      end
    end

    # Using #variants_including_master everywhere (instead of #has_variants? and #master),
    # so that when including relations to avoid N+1 on product grid (where this #cheapest_variant method is used)
    # we only have to includes variants_including_master (instead of master and variants)
    def cheapest_variant
      return variants_including_master.take if variants_including_master.size == 1

      variants_including_master.reject(&:is_master).min_by(&:price)
    end

    def find_variant_by_options_hash(options_hash)
      variants.includes(:option_values).detect { |variant| variant.options_hash == options_hash }
    end

    Spree::Product.prepend self
  end
end
