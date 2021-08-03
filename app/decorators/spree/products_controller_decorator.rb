# frozen_string_literal:true

module Spree
  module ProductsControllerDecorator
    def index
      super

      @brands = Spree::Taxon.find_by(name: 'Brands').children
    end

    Spree::ProductsController.prepend self
  end
end
