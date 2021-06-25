# frozen_string_literal: true

module Spree
  module VariantDecorator
    def self.prepended(base)
      base.validates :repair_shopr_id, uniqueness: true, allow_nil: true
    end

    def destroy_and_destroy_product_if_no_other_variants!
      product = self.product
      destroy!
      product.destroy! unless product.reload.has_variants?
    end

    Spree::Variant.prepend self
  end
end
