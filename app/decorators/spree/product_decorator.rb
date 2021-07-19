# frozen_string_literal: true

module Spree
  module ProductDecorator
    def self.prepended(base)
      base.scope :ascend_by_purchase_count, -> { order(purchase_count: :asc) }
      base.scope :descend_by_purchase_count, -> { order(purchase_count: :desc) }
      base.scope :ascend_by_created_at, -> { order(created_at: :asc) }
      base.scope :descend_by_created_at, -> { order(created_at: :desc) }

      # add_search_scope :on_sale do
      #   where('spree_products.* , spree_prices.amount')
      #                                 .order(Spree::Price.arel_table[:amount].asc)
      # end
    end

    Spree::Product.prepend self
  end
end
