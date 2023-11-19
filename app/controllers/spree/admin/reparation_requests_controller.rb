# frozen_string_literal:true

module Spree
  module Admin
    class ReparationRequestsController < Spree::Admin::BaseController
      def index
        @reparation_requests = ReparationRequest.all.order(created_at: :desc).page(params[:page])
      end
    end
  end
end