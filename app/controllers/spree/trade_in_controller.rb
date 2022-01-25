# frozen_string_literal:true

module Spree
  class TradeInController < Spree::StoreController
    def index
      @trade_in_categories = TradeInCategory.all

      # @trade_in_models_options = @trade_in_categories.map do |category|
      #   {
      #     category_id: category.id,
      #     model_options: category.trade_in_models.map { |model| [model.name, model.id] },
      #     model_prices: category.trade_in_models.map { |model| [model.min_value, model.max_value] }
      #   }
      # end

      @trade_in_models = TradeInModel.all
    end

    def show
      @trade_in_category = TradeInCategory.find(params[:id])
      @trade_in_models = @trade_in_category.trade_in_models
      @trade_in_models_select_options = @trade_in_models.map { |model| [model.name, model.id] }
    end
  end
end
