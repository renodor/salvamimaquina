# frozen_string_literal: true

module Spree
  module CouponCodesControllerDecorator
    def self.prepended(base)
      base.before_action :load_order, only: %i[create remove]
      base.around_action :lock_order, only: %i[create remove]
    end

    def create
      authorize! :update, @order, cookies.signed[:guest_token]

      return if params[:coupon_code].blank?

      @order.coupon_code = params[:coupon_code]
      handler = PromotionHandler::Coupon.new(@order).apply

      respond_with(@order) do |format|
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
      handler = PromotionHandler::Coupon.new(@order).remove

      respond_with(@order) do |format|
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

    Spree::CouponCodesController.prepend self
  end
end
