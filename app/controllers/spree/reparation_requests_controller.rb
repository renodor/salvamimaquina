# frozen_string_literal:true

module Spree
  class ReparationRequestsController < Spree::StoreController
    def new
      @category = ReparationCategory.find(params[:reparation_category_id])
      @reparation_request = ReparationRequest.new
    end

    def create
      @reparation_request = ReparationRequest.new(reparation_request_params)
      @reparation_request.reparation_category = ReparationCategory.find(params[:reparation_category_id])
      if @reparation_request.save
        redirect_to reparation_requests_thank_you_path
      else
        @category = ReparationCategory.find(params[:reparation_category_id])
        render :new
      end
    end

    def thank_you; end

    private

    def reparation_request_params
      params.require(:reparation_request).permit(:product, :damage, :shop, :name, :email, :comment)
    end
  end
end
