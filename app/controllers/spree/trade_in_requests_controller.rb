# frozen_string_literal:true

module Spree
  class TradeInRequestsController < Spree::StoreController
    def new
      @trade_in_categories = TradeInCategory.all
      @trade_in_models = TradeInModel.all.includes(:trade_in_category)
      @taxons = Taxon.where(depth: 1)
      @accessories_taxon_id = Spree::Taxon.find_by(name: 'Accesorios').id
      @products = Spree::Product.all.includes(:variants, :master, :taxons).order(:name)
      @variants = Spree::Variant.where(is_master: false).includes(:product, [option_values: :option_type]).order(:product_id)

      @trade_in_request = TradeInRequest.new
    end

    def create; end

    def variant_infos
      variant = Spree::Variant.find(params[:id])
      render json: {
        tradeInIsValid: params[:trade_in_max_value].to_f < variant.price,
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
