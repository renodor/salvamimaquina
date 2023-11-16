# frozen_string_literal: true

module Spree
  module StateOverride
    def self.prepended(base)
      base.has_many :districts, -> { order(:name) }, dependent: :destroy
    end

    Spree::State.prepend self
  end
end
