# frozen_string_literal: true

module Spree
  module OrdersControllerDecorator
    def self.prepended(base)
      base.before_action :send_mapbox_api_key_to_frontend, only: :show
    end

    def edit
      super

      gon.order_info = {
        number: @order.number,
        guest_token: @order.guest_token
      }
    end

    # Adds a new item to the order (creating a new order if none already exists)
    # (Need to decorate this method only to modify the last redirect_to line to redirect to the es_MX path...)
    # def populate
    #   @order = current_order(create_order_if_necessary: true)
    #   authorize! :update, @order, cookies.signed[:guest_token]

    #   variant  = Spree::Variant.find(params[:variant_id])
    #   quantity = params[:quantity].present? ? params[:quantity].to_i : 1

    #   # 2,147,483,647 is crazy. See issue https://github.com/spree/spree/issues/2695.
    #   if quantity.between?(1, 2_147_483_647)
    #     begin
    #       @line_item = @order.contents.add(variant, quantity)
    #     rescue ActiveRecord::RecordInvalid => error
    #       @order.errors.add(:base, error.record.errors.full_messages.join(", "))
    #     end
    #   else
    #     @order.errors.add(:base, t('spree.please_enter_reasonable_quantity'))
    #   end

    #   respond_with(@order) do |format|
    #     format.html do
    #       if @order.errors.any?
    #         flash[:error] = @order.errors.full_messages.join(", ")
    #         redirect_back_or_default(spree.root_path)
    #         return
    #       else
    #         redirect_to cart_es_mx_path
    #       end
    #     end
    #   end
    # end

    private

    def send_mapbox_api_key_to_frontend
      gon.mapbox_api_key = Rails.application.credentials.mapbox_api_key
    end

    Spree::OrdersController.prepend self
  end
end
