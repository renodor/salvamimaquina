# frozen_string_literal: true

module Spree
  module TaxonsControllerDecorator
    def show
      @categories = @taxon.children
      @searcher = build_searcher(params.merge(taxon_id: @taxon.id))
      @products = @searcher.retrieve_products.includes(variants_including_master: [{ images: [attachment_attachment: :blob] }, { prices: :active_sale_prices }])
      @products = @products.descend_by_available_on # Currently our default sorting
    end

    Spree::TaxonsController.prepend self
  end
end
