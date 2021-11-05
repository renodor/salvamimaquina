# frozen_string_literal:true

module Spree
  module ProductsControllerDecorator
    def index
      @taxonomies = Spree::Taxonomy.includes(root: :children)
      @categories_taxon = Spree::Taxon.includes(children: :icon_attachment).find_by(name: 'Categories')
      @banner = Banner.find_by(location: :shop)
    end

    def show
      @variants = @product.variants.includes(prices: :active_sale_prices)
      @master = @product.master
      @product_has_variant = @product.has_variants?

      @product_images = @product.gallery.images.includes(attachment_attachment: :blob)

      # Maybe not needed because when we sync we don't add image to product master if it adds variant? (But not sure... To be confirmed)
      @product_images = @product_images.where.not(viewable_id: @master.id) if @product_has_variant
    end

    def product_variants_with_option_values
      product = Spree::Product.find(params[:product_id])
      variant_ids = product.variants.has_option(OptionType.find(params[:selected_option_type]), OptionValue.find(params[:selected_option_value])).pluck(:id)
      render json: Spree::Variant.option_values_by_option_type(variant_ids)
    end

    def variant_with_options_hash
      options_hash = params[:variant_options].permit!.to_h.each_with_object({}) do |(key, value), hash|
        hash[key.delete('option_type_').to_i] = value.to_i
      end

      variant = Spree::Product.find(params[:product_id]).find_variant_by_options_hash(options_hash)
      variant_image_key = variant.images.first&.attachment&.key
      render json: {
        id: variant.id,
        onSale: variant.on_sale?,
        price: ActionController::Base.helpers.number_to_currency(variant.original_price),
        discountPrice: ActionController::Base.helpers.number_to_currency(variant.price),
        hasStock: variant.can_supply?,
        imageKey: variant_image_key,
        imageUrl: variant_image_key ? ActionController::Base.helpers.cl_image_path(variant_image_key) : nil
      }
    end

    Spree::ProductsController.prepend self
  end
end
