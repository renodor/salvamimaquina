# frozen_string_literal: true

module Spree
  module ProductOverride
    extend ActiveSupport::Concern

    prepended do
      scope :ascend_by_purchase_count, -> { order(purchase_count: :asc) }
      scope :descend_by_purchase_count, -> { order(purchase_count: :desc) }
      scope :ascend_by_available_on, -> { order(available_on: :asc) }
      scope :descend_by_available_on, -> { order(available_on: :desc) }
      add_search_scope :with_option do |option_type_id, option_value_id| # option_value_id can be one single id or an array of ids, it works the same
        joins(:option_types, variants_including_master: :option_values)
          .where(option_types: { id: option_type_id }, option_values: { id: option_value_id })
          .distinct
      end

      # Modify the solidus in_taxon scope to remove ordering and thus greatly simplify its SQL
      add_search_scope :in_taxon do |taxon|
        joins(:taxons).where('spree_taxons' => { id: taxon.self_and_descendants.pluck(:id) })
      end

      add_search_scope :price_between do |min, max|
        min, max = max, min if min.to_i > max.to_i

        left_outer_joins(:variants, :prices)
          .distinct
          .where('spree_prices.amount BETWEEN ? AND ?', min, max)
      end
    end

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

    Spree::Product.prepend self
  end
end
