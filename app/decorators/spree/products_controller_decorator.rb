# frozen_string_literal:true

module Spree
  module ProductsControllerDecorator
    def index
      @taxonomies = Spree::Taxonomy.includes(root: :children)
      @categories_taxon = Spree::Taxon.includes(children: :icon_attachment).find_by(name: 'Categories')
      @banner = Banner.find_by(location: :shop)
    end

    def show
      @variants = @product.variants.includes(:stock_items, option_values: :option_type, prices: :active_sale_prices)
      @master = @product.master

      # @product_properties = @product.product_properties.includes(:property)
      # @taxon = Spree::Taxon.find(params[:taxon_id]) if params[:taxon_id]

      @product_images = @product.gallery.images.includes(attachment_attachment: :blob)
    end

    def product_variants_with_option_values
      product = Spree::Product.find(params[:product_id])
      variants = product.variants.has_option(OptionType.find(params[:option_type]), OptionValue.find(params[:option_value]))
      render json: {
        variants: variants
        # option_values_by_option_type: product.variant_option_values_by_option_type(variants.pluck(:id))
      }
    end

    Spree::ProductsController.prepend self
  end
end
