# frozen_string_literal: true

class CouponCodesController < StoreController
  before_action :load_order, only: %i[create remove]
  around_action :lock_order, only: %i[create remove]

  def create
    authorize! :update, @order, cookies.signed[:guest_token]

    return if params[:coupon_code].blank?

    @order.coupon_code = params[:coupon_code]
    handler = Spree::PromotionHandler::Coupon.new(@order).apply

    respond_to do |format|
      format.html do
        if handler.successful?
          flash[:success] = handler.success
        else
          flash[:error] = handler.error
        end

        redirect_back(fallback_location: checkout_state_path(@order.state))
      end
    end
  end

  def remove
    authorize! :update, @order, cookies.signed[:guest_token]

    @order.coupon_code = params[:id]
    handler = Spree::PromotionHandler::Coupon.new(@order).remove

    if handler.successful?
      flash[:success] = handler.success
    else
      flash[:error] = handler.error
    end

    redirect_back(fallback_location: checkout_state_path(@order.state))
  end

  private

  def load_order
    @order = current_order
  end
end
