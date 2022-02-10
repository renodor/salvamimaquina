# frozen_string_literal:true

module Spree
  module Admin
    class TradeInModelsController < Spree::Admin::BaseController
      def index
        @trade_in_models = TradeInModel.all
      end

      def sync
        ImportTradeInFromGoogleSheet.call
        redirect_to admin_trade_in_models_path
      end
    end
  end
end
