# frozen_string_literal: true

class ProductsController < StoreController
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
    # TODO: the :with_option scope is used for model, color and capacity filters which means we don't cumulate those filters
    # because in Spree::Core::Search::BaseOverride#add_search_scopes we call :with_option scope only once with the first option_type_id received.
    # If we want to cumulate those, we should have one specific scope per filter, call :with_option scope for every received option_type_id
    @searcher = build_searcher(products_filters_params)
    @products = @searcher
                .retrieve_products
                .includes(variants_including_master: [{ images: [attachment_attachment: :blob] }, :prices])

    return unless Spree::Product.sorting_options.keys.include?(params[:products_sorting]&.to_sym)

    # TOOD: sort_products should be normal product scopes applied when doing build_searcher.retrieve_products...
    # We currently apply it afterward like that because the "ascend_by_price" and "descend_by_price" sorting are not a real scope
    # As soon as we will refacto product price into its own module (something like solidus Spree::DefaultPrice),
    # we will be able to create normals :ascend_by_price and :descend_by_price scopes and thus apply sort_products with other scopes
    @products = case params[:products_sorting]
                when 'ascend_by_price'
                  @products.sort_by { |product| product.cheapest_variant.price }
                when 'descend_by_price'
                  @products.sort_by { |product| - product.cheapest_variant.price }
                else
                  @products.send(params[:products_sorting])
                end

    @current_sorting_key = params[:products_sorting]
  end

  def search_results
    @products = Spree::Product
                .in_name_or_description(params.dig(:products_search, :keywords))
                .includes(variants_including_master: [{ images: [attachment_attachment: :blob] }, :prices])

    @current_sorting_key = params[:products_sorting]
  end

  private

  def products_filters_params
    # TODO: authenticity_token params is flagged as unpermitted here...
    params.require(:products_filters).permit(:per_page, :taxon_id, search: {}, scopes: [], price_between: [])
  end
end
