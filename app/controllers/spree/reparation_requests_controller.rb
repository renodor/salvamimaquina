# frozen_string_literal:true

module Spree
  class ReparationRequestsController < Spree::StoreController
    def new
      @category = ReparationCategory.find(params[:reparation_category_id])
      @reparation_request = ReparationRequest.new
    end
  end
end
