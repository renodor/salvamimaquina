# frozen_string_literal:true

module Spree
  module Admin
    class ReparationRequestsController < Spree::Admin::BaseController
      def index
        @reparation_requests = ReparationRequest.all
      end
    end
  end
end
