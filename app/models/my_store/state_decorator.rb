# frozen_string_literal: true

module MyStore
  module StateDecorator
    def self.prepended(base)
      base.has_many :districts
    end

    Spree::State.prepend self
  end
end
