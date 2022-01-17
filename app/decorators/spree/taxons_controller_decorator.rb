# frozen_string_literal: true

module Spree
  module TaxonsControllerDecorator
    def self.prepended(base)
      base.before_action :load_taxon, :retrieve_products
    end

    def show
      @categories = Spree::Taxon.includes(children: :children).find_by(name: 'Categories').children
      @products = @products.descend_by_available_on # Currently our default sorting
    end

    def filter_products
      render json: { products: products_with_aditional_data, noProductsMessage: t('spree.no_products_found') }
    end

    private

    def retrieve_products
      safe_params = product_filters_params
      @searcher = build_searcher(safe_params.merge(taxon: @taxon.id))
      @products = @searcher.retrieve_products.includes(variants_including_master: [{ images: [attachment_attachment: :blob] }, { prices: :active_sale_prices }])
      sort_products(safe_params[:sort_products]) if Spree::Product.sorting_options.keys.include?(safe_params[:sort_products]&.to_sym)
    end

    # TOOD: sort_products should be normal product scopes applied when doing build_searcher.retrieve_products...
    # We currently apply it afterward like that because the "ascend_by_price" and "descend_by_price" sorting are not a real scope
    # As soon as we will refacto product price into its own module (something like solidus Spree::DefaultPrice),
    # we will be able to create normals :ascend_by_price and :descend_by_price scopes and thus apply sort_products with other scopes
    def sort_products(sort_params)
      @products = case sort_params
                  when 'ascend_by_price'
                    @products.sort_by { |product| product.cheapest_variant.price }
                  when 'descend_by_price'
                    @products.sort_by { |product| - product.cheapest_variant.price }
                  else
                    @products.send(sort_params)
                  end
    end

    def products_with_aditional_data
      @products.map do |product|
        cheapest_variant = product.cheapest_variant
        product_image = cheapest_variant.images.first&.attachment
        aditional_data = {
          url: spree.product_path(product, taxon_id: @taxon.try(:id)),
          image_url: product_image&.key ? helpers.cl_image_path_with_folder(product_image, width: 540, crop: :fill) : nil,
          cheapest_variant_onsale: cheapest_variant.on_sale?,
          discount_price: cheapest_variant.price,
          discount_price_html_tag: helpers.number_to_currency(cheapest_variant.price),
          price: cheapest_variant.original_price,
          price_html_tag: helpers.number_to_currency(cheapest_variant.original_price)
        }

        product.as_json.merge(aditional_data)
      end
    end

    def product_filters_params
      params.permit(:per_page, :id, :sort_products, scopes: {}, search: {}, price_between: [])
    end

    Spree::TaxonsController.prepend self
  end
end
