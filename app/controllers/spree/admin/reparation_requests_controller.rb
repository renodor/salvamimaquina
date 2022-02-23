# frozen_string_literal:true

module Spree
  module Admin
    class ReparationRequestsController < Spree::Admin::BaseController
      def index
        @reparation_requests = ReparationRequest.all.order(created_at: :desc).limit(1000) # TODO: paginate instead of limiting
      end
    end
  end
end
