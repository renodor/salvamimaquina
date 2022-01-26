# frozen_string_literal:true

module Spree
  class TradeInController < Spree::StoreController
    def index
      @trade_in_categories = TradeInCategory.all.includes(:trade_in_models)
      @trade_in_models = TradeInModel.all
      @taxons = Taxon.where(depth: 1)
      @products = Spree::Product.all.includes(:variants).order(:name)
      @variants = Spree::Variant.all.includes(:product, [option_values: :option_type]).order(:product_id)
    end

    def show
      @trade_in_category = TradeInCategory.find(params[:id])
      @trade_in_models = @trade_in_category.trade_in_models
      @trade_in_models_select_options = @trade_in_models.map { |model| [model.name, model.id] }
    end
  end
end
