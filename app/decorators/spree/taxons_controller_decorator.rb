# frozen_string_literal: true

module Spree
  module TaxonsControllerDecorator
    def show
      set_categories
      @searcher = build_searcher(params.merge(taxon_id: @taxon.id))
      @products = @searcher.retrieve_products.includes(variants_including_master: [{ images: [attachment_attachment: :blob] }, { prices: :active_sale_prices }])
      @products = @products.descend_by_available_on # Currently our default sorting
    end

    private

    def set_categories
      if @taxon.depth.zero?
        @categories = Spree::Taxon.find_by(depth: 0).children
      else
        @categories = @taxon.children
        @parent_category = @taxon.parent
      end
    end

    Spree::TaxonsController.prepend self
  end
end
