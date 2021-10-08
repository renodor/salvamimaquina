# frozen_string_literal:true

module Spree
  module ProductsControllerDecorator
    def index
      @taxonomies = Spree::Taxonomy.includes(root: :children)
      @categories_taxon = Spree::Taxon.includes(children: :icon_attachment).find_by(name: 'Categories')
    end

    def show
      @variants = @product.variants.includes(:stock_items, option_values: :option_type, prices: :active_sale_prices)
      @master = @product.master

      # @product_properties = @product.product_properties.includes(:property)
      # @taxon = Spree::Taxon.find(params[:taxon_id]) if params[:taxon_id]

      @product_images = @product.gallery.images.includes(attachment_attachment: :blob)
    end

    Spree::ProductsController.prepend self
  end
end
