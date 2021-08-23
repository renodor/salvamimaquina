# frozen_string_literal: true

module Spree
  module ProductDecorator
    def self.prepended(base)
      base.scope :ascend_by_purchase_count, -> { order(purchase_count: :asc) }
      base.scope :descend_by_purchase_count, -> { order(purchase_count: :desc) }
      base.scope :ascend_by_created_at, -> { order(created_at: :asc) }
      base.scope :descend_by_created_at, -> { order(created_at: :desc) }
      base.scope :on_sale, -> { joins(:sale_prices).where('start_at <= ? OR start_at IS NULL) AND (end_at >= ? OR end_at IS NULL', Time.now, Time.now).distinct }

      base.add_search_scope :with_option do |option_type_id, option_value_id| # option_value_id can be one single id or an array of ids, it works the same
        joins(:option_types, variants_including_master: :option_values)
          .where(option_types: { id: option_type_id }, option_values: { id: option_value_id })
      end

      base.add_search_scope :price_between do |min, max|
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

    def cheapest_variant
      return master unless has_variants?

      variants.min_by(&:price)
    end

    Spree::Product.prepend self
  end
end
