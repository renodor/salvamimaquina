# frozen_string_literal:true

module Spree
  module Admin
    class TradeInRequestsController < Spree::Admin::BaseController
      def index
        @trade_in_requests = TradeInRequest.all.order(created_at: :desc).limit(1000) # TODO: paginate instead of limiting
      end
    end
  end
end
