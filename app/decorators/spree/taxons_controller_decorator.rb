# frozen_string_literal: true

module Spree
  module TaxonsControllerDecorator
    def show
      @searcher = build_searcher(params.merge(taxon: @taxon.id, include_images: true))
      @products = @searcher.retrieve_products
      @taxonomies = Spree::Taxonomy.includes(root: :children)

      respond_to do |format|
        format.html
        format.json do
          render json: { products: products_with_aditional_data, noProductsMessage: t('spree.no_products_found') }
        end
      end
    end

    private

    def products_with_aditional_data
      @products.map do |product|
        discount_price = product.cheapest_variant.price_for(current_pricing_options)
        price = product.cheapest_variant.price_for(current_pricing_options, sale_price: false)
        aditional_data = {
          url: spree.product_path(product, taxon_id: @taxon.try(:id)),
          cheapest_variant_onsale: product.cheapest_variant.on_sale?,
          discount_price: discount_price.to_d,
          discount_price_html_tag: discount_price.to_html,
          price: price.to_d,
          price_html_tag: price.to_html
        }

        product.as_json.merge(aditional_data)
      end
    end

    Spree::TaxonsController.prepend self
  end
end
