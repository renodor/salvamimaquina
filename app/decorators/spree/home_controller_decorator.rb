# frozen_string_literal: true

module Spree
  module HomeControllerDecorator
    def self.prepended(base)
      base.layout 'homepage'
    end

    Spree::HomeController.prepend self
  end
end
