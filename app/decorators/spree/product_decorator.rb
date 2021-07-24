# frozen_string_literal: true

module Spree
  module ProductDecorator
    def self.prepended(base)
      base.scope :ascend_by_purchase_count, -> { order(purchase_count: :asc) }
      base.scope :descend_by_purchase_count, -> { order(purchase_count: :desc) }
      base.scope :ascend_by_created_at, -> { order(created_at: :asc) }
      base.scope :descend_by_created_at, -> { order(created_at: :desc) }
      base.scope :on_sale, -> { joins(:sale_prices).where('start_at <= ? OR start_at IS NULL) AND (end_at >= ? OR end_at IS NULL', Time.now, Time.now).distinct }
    end

    def cheapest_variant
      prices.min_by(&:amount).variant
    end

    Spree::Product.prepend self
  end
end
