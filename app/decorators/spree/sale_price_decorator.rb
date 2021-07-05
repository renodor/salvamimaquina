# frozen_string_literal: true

module Spree
  module SalePriceDecorator
    def self.prepended(base)
      # The SQL statement in the original code was raising an error...
      base.scope :ordered, -> { where.not(start_at: nil).order(start_at: :asc) }
    end

    Spree::SalePrice.prepend self
  end
end
