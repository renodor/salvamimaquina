# frozen_string_literal:true

module Spree
  module Admin
    class TradeInModelsController < Spree::Admin::BaseController
      def index
        @trade_in_models = TradeInModel.all.order(:order)
      end

      def sync
        payload = SyncTradeInModels.call

        if payload[:success?]
          flash[:success] = 'Trade in models Synchronized correctly'
        else
          flash[:error] = "Trade in models couldn't be synchronized, please review your Google Sheet file and try again"
        end
        redirect_to admin_trade_in_models_path
      end
    end
  end
end