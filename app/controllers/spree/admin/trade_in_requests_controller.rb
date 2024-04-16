# frozen_string_literal:true

module Spree
  module Admin
    class TradeInRequestsController < Spree::Admin::BaseController
      def index
        @trade_in_requests = TradeInRequest.all.order(created_at: :desc).page(params[:page])
      end
    end
  end
end
