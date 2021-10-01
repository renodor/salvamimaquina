# frozen_string_literal: true

module Spree
  module TaxonsControllerDecorator
    def self.prepended(base)
      base.before_action :load_taxon, :retrieve_products
    end

    def show
      @brands = Spree::Taxon.includes(children: :children).find_by(name: 'Brands').children
    end

    def filter_products
      render json: { products: products_with_aditional_data, noProductsMessage: t('spree.no_products_found') }
    end

    private

    def retrieve_products
      @searcher = build_searcher(params.merge(taxon: @taxon.id))
      @products = @searcher.retrieve_products.includes(variants_including_master: [{ images: [attachment_attachment: :blob] }, { prices: :active_sale_prices }])
    end

    def products_with_aditional_data
      @products.map do |product|
        product.name = helpers.branded_name(product.name)
        cheapest_variant = product.cheapest_variant
        product_image_key = cheapest_variant.images.first&.attachment&.key
        aditional_data = {
          url: spree.product_path(product, taxon_id: @taxon.try(:id)),
          image_url: product_image_key ? "https://res-5.cloudinary.com/detkhu57i/image/upload/c_fill,w_540/#{product_image_key}" : nil, # TODO: don't harcode this link,
          cheapest_variant_onsale: cheapest_variant.on_sale?,
          discount_price: cheapest_variant.price,
          discount_price_html_tag: ActionController::Base.helpers.number_to_currency(cheapest_variant.price),
          price: cheapest_variant.original_price,
          price_html_tag: ActionController::Base.helpers.number_to_currency(cheapest_variant.original_price)
        }

        product.as_json.merge(aditional_data)
      end
    end

    Spree::TaxonsController.prepend self
  end
end
