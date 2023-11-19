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
    @product = @products.friendly.find(params[:id])
    @variants = @product.variants.includes(prices: :active_sale_prices)
    @master = @product.master
    @current_variant = @product.variants.find_by(id: variant_params['variant_id'])
    @product_has_variant = @product.has_variants?

    @product_images = @product.gallery.images.includes(attachment_attachment: :blob)

    if @product_has_variant
      # Maybe not needed because when we sync we don't add image to product master if it has variants? (But not sure... To be confirmed)
      @product_images = @product_images.where.not(viewable_id: @master.id)
    else
      # If product has no variants we will display the first image by default. We need it to have the correct thumbnail "selected"
      @first_image = @product_images.first&.attachment
    end
  end

  # Takes the current product (thanks to params[:product_id])
  # Search among this product variants the ones that have the selected option values (thanks to params[:selected_option_type] and params[:selected_option_value])
  # Then returns a hash of those variants Spree::OptionValue grouped by Spree::OptionType
  def product_variants_with_option_values
    product = Spree::Product.find(params[:product_id])
    variant_ids = product.variants.has_option(OptionType.find(params[:selected_option_type]), OptionValue.find(params[:selected_option_value])).pluck(:id)
    render json: Spree::Variant.option_values_by_option_type(variant_ids)
  end

  # Find the product variant that have the corresponding variant options,
  # using params[:variant_options] and Spree::Product#find_variant_by_options_hash.
  # Then build a JSON with all the needed variant info to update it with JS on product show.
  def variant_with_options_hash
    options_hash = params[:variant_options].to_unsafe_h.each_with_object({}) do |(key, value), hash|
      hash[key.delete('option_type_').to_i] = value.to_i
    end

    variant = Spree::Product.find(params[:product_id]).find_variant_by_options_hash(options_hash)
    variant_image_key = variant.images.first&.attachment&.key
    render json: {
      id: variant.id,
      onSale: variant.on_sale?,
      price: helpers.number_to_currency(variant.original_price),
      discountPrice: helpers.number_to_currency(variant.price),
      totalStock: variant.total_on_hand,
      imageKey: variant_image_key,
      imageUrl: helpers.cl_image_path_with_folder(variant.images.first&.attachment, width: 600, crop: :fit, model: Spree::Image),
      imageAlt: "#{variant.product.name} - #{variant.options_text}",
      condition: variant.condition
    }
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

  def variant_params
    params.permit(:variant_id)
  end
end
