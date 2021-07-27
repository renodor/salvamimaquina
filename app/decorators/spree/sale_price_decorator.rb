# frozen_string_literal: true

require 'active_support/concern'

module Spree
  module SalePriceDecorator
    def self.prepended(base)
      # The SQL statement in the original code was raising an error...
      base.scope :ordered, -> { order(start_at: :asc) }
      base.validate :dont_apply_on_master_variant
    end

    def dont_apply_on_master_variant
      # TODO: add visual explaination on front end when this happen
      errors.add(:base, 'Cannot create sale price on master variant of a product with variants') if price.variant.is_master? && price.variant.product.has_variants?
    end

    Spree::SalePrice.prepend self
  end
end
