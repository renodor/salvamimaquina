# frozen_string_literal: true

class ProductsController < StoreController
  helper 'spree/products', 'spree/taxons', 'taxon_filters'

  respond_to :html

  rescue_from Spree::Config.searcher_class::InvalidOptions do |error|
    raise ActionController::BadRequest.new, error.message
  end

  def index
    @taxonomies = Spree::Taxonomy.includes(root: :children)
    @root_taxon = Spree::Taxon.includes(children: [icon_attachment: :blob]).find_by(depth: 0)
    @slider = Slider.find_by(location: :products)
  end

  def show
    @product = Spree::Product.friendly.find(params[:id])
    @variant = @product.variants.find_by(id: params[:variant_id]) || @product.cheapest_variant
  end

  def select_variant
    @product = Spree::Product.friendly.find(params[:id])
    selected_option_ids = params[:option_value_ids].compact_blank.map(&:to_i)
    # TODO: find a better way to retrieve this variant
    @variant = @product.variants.detect { |variant| (variant.option_value_ids - selected_option_ids).blank? }
  end

  def filter
    retrieve_products
    render json: { products: products_with_aditional_data, noProductsMessage: t('spree.no_products_found') }
  end

  def search_results
    @products = Spree::Product
                .in_name_or_description(product_filters_params[:keywords])
                .includes(variants_including_master: [{ images: [attachment_attachment: :blob] }, { prices: :active_sale_prices }])
  end

  private

  def retrieve_products
    @searcher = build_searcher(product_filters_params)
    @products = @searcher
                .retrieve_products
                .includes(variants_including_master: [{ images: [attachment_attachment: :blob] }, { prices: :active_sale_prices }])
    @products = sort_products(product_filters_params[:sort_products]) if Spree::Product.sorting_options.keys.include?(product_filters_params[:sort_products]&.to_sym)
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
      aditional_data = {
        url: product_path(product, taxon_id: @taxon.try(:id)),
        image_url: helpers.cl_image_path_with_folder(cheapest_variant.images.first&.attachment, width: 540, crop: :fill, model: Spree::Image),
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
    params.permit(:per_page, :taxon_id, :sort_products, :keywords, scopes: {}, search: {}, price_between: [])
  end
end
