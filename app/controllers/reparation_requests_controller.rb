# frozen_string_literal:true

class ReparationRequestsController < StoreController
  def new
    @category = ReparationCategory.find(params[:reparation_category_id])
    @reparation_request = ReparationRequest.new
  end

  def create
    @reparation_request = ReparationRequest.new(reparation_request_params)
    @reparation_request.reparation_category = ReparationCategory.find(params[:reparation_category_id])
    if @reparation_request.save
      AdminNotificationMailer.reparation_request_email(@reparation_request).deliver_later
      redirect_to reparation_requests_thank_you_path
    else
      @category = ReparationCategory.find(params[:reparation_category_id])
      render :new, status: :unauthorized
    end
  end

  def thank_you; end

  private

  def reparation_request_params
    params.require(:reparation_request).permit(:product, :damage, :shop, :name, :email, :phone, :comment)
  end
end
