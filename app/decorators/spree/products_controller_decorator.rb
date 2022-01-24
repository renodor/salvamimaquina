# frozen_string_literal:true

module Spree
  module ProductsControllerDecorator
    def index
      @taxonomies = Spree::Taxonomy.includes(root: :children)
      @categories_taxon = Spree::Taxon.includes(children: [icon_attachment: :blob]).find_by(name: 'Categories')
      @banner = Banner.find_by(location: :shop)
    end

    def show
      @variants = @product.variants.includes(prices: :active_sale_prices)
      @master = @product.master
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
    # Search among this product variants the ones that have the selected option values (thanks to params[:seelcted_option_type] and params[:selected_option_value])
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
        imageUrl: helpers.cl_image_path_with_folder(variant.images.first&.attachment, width: 600, crop: :fit, model: Spree::Image)
      }
    end

    Spree::ProductsController.prepend self
  end
end
