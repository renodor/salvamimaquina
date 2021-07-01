# frozen_string_literal: true

module Spree
  module SalePriceDecorator
    def self.prepended(base)
      base.scope :ordered, -> { where.not(start_at: nil).order(start_at: :asc) }
    end

    Spree::SalePrice.prepend self
  end
end
