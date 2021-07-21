# frozen_string_literal: true

require 'active_support/concern'

module Spree
  module SalePriceDecorator
    extend ActiveSupport::Concern

    def self.prepended(base)
      # The SQL statement in the original code was raising an error...
      base.scope :ordered, -> { order(start_at: :asc) }
    end

    class_methods do
      def for_product(product)
        ids = product.variants_including_master
        where(price_id: Spree::Price.where(variant_id: ids))
      end
    end

    Spree::SalePrice.prepend self
  end
end
