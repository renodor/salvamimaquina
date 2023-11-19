# frozen_string_literal: true

class TaxonsController < StoreController
  helper 'spree/taxons', 'spree/products', 'taxon_filters'

  before_action :load_taxon, only: [:show]

  respond_to :html

  def show
    @categories = @taxon.children
    @searcher = build_searcher(params.merge(taxon_id: @taxon.id))
    @products = @searcher.retrieve_products.includes(variants_including_master: [{ images: [attachment_attachment: :blob] }, { prices: :active_sale_prices }])
    @products = @products.descend_by_available_on # Currently our default sorting
  end

  private

  def load_taxon
    @taxon = Spree::Taxon.find_by!(permalink: params[:id])
  end

  def accurate_title
    if @taxon
      @taxon.seo_title
    else
      super
    end
  end
end
