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
    # (Decorate this method only to modify the last redirect_to line to redirect to the es_MX path...)
    def populate
      @order = current_order(create_order_if_necessary: true)
      authorize! :update, @order, cookies.signed[:guest_token]

      variant  = Spree::Variant.find(params[:variant_id])
      quantity = params[:quantity].present? ? params[:quantity].to_i : 1

      # 2,147,483,647 is crazy. See issue https://github.com/spree/spree/issues/2695.
      if quantity.between?(1, 2_147_483_647)
        begin
          @line_item = @order.contents.add(variant, quantity)
        rescue ActiveRecord::RecordInvalid => e
          @order.errors.add(:base, e.record.errors.full_messages.join(', '))
        end
      else
        @order.errors.add(:base, t('spree.please_enter_reasonable_quantity'))
      end

      @order.errors.add(:base, t('spree.please_enter_reasonable_quantity'))
      @order.errors.add(:base, 'another error')

      if @order.errors.any?
        # Not confident to display any order error on front end as it is (maybe not clear to understand)
        # so instead we display a generic error and send the real error to Sentry
        Sentry.capture_message(
          'Error when adding variant to cart',
          {
            extra: {
              errors: @order.errors.messages,
              order: @order.as_json,
              variant: variant.as_json
            }
          }
        )
        render json: {
          error: t('spree.cant_add_to_cart')
        }, status: 422
      else
        render json: {
          variantName: "#{variant.product.name} - #{variant.options_text}",
          quantity: quantity
        }
      end
    end

    private

    def send_mapbox_api_key_to_frontend
      gon.mapbox_api_key = Rails.application.credentials.mapbox_api_key
    end

    Spree::OrdersController.prepend self
  end
end
