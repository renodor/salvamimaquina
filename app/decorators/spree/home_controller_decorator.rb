# frozen_string_literal: true

module Spree
  module HomeControllerDecorator
    def self.prepended(base)
      base.layout 'homepage'
    end

    def index
      @products = Spree::Product.where(highlight: true).limit(4)
    end

    Spree::HomeController.prepend self
  end
end
