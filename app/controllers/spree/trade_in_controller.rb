# frozen_string_literal:true

module Spree
  class TradeInController < Spree::StoreController
    def index
      @trade_in_categories = TradeInCategory.all.includes(:trade_in_models)
      @trade_in_models = TradeInModel.all
      @taxons = Taxon.where(depth: 1)
      @accessories_taxon_id = Spree::Taxon.find_by(name: 'Accesorios').id
      @products = Spree::Product.all.includes(:variants).order(:name)
      @variants = Spree::Variant.all.includes(:product, [option_values: :option_type]).order(:product_id)
    end

    def show
      @trade_in_category = TradeInCategory.find(params[:id])
      @trade_in_models = @trade_in_category.trade_in_models
      @trade_in_models_select_options = @trade_in_models.map { |model| [model.name, model.id] }
    end

    def variant_infos
      variant = Spree::Variant.find(params[:id])
      render json: {
        name: variant.name,
        price: helpers.number_to_currency(variant.price),
        options: variant.options_text,
        imageTag: helpers.cl_image_tag_with_folder(variant.images.first&.attachment, width: 200, crop: :fill, model: Spree::Image),
        minValue: helpers.number_to_currency(variant.price - params[:trade_in_min_value].to_f),
        maxValue: helpers.number_to_currency(variant.price - params[:trade_in_max_value].to_f)
      }
    end
  end
end
