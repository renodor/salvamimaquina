# frozen_string_literal: true

class CartLineItemsController < StoreController
  helper 'spree/products', 'orders'

  respond_to :html

  before_action :store_guest_token
  skip_before_action :verify_authenticity_token

  # Adds a new item to the order (creating a new order if none already exists)
  def create
    @order = current_order(create_order_if_necessary: true)
    authorize! :update, @order, cookies.signed[:guest_token]

    variant  = Spree::Variant.find(params[:variant_id])
    quantity = params[:quantity].present? ? params[:quantity].to_i : 1

    # 2,147,483,647 is crazy. See issue https://github.com/spree/spree/issues/2695.
    if quantity.between?(1, 2_147_483_647)
      begin
        @line_item = @order.contents.add(variant, quantity)
      rescue ActiveRecord::RecordInvalid => error
        @order.errors.add(:base, error.record.errors.full_messages.join(", "))
      end
    else
      @order.errors.add(:base, t('spree.please_enter_reasonable_quantity'))
    end

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
        flash: helpers.build_flash('error', t('spree.cant_add_to_cart'))
      }, status: 422
    else
      options_text = variant.options_text
      variant_full_name = options_text.present? ? "#{variant.product.name} - #{variant.options_text}" : variant.product.name
      # render json: {
      #   variantName: variant_full_name,
      #   quantity: quantity
      # }

      # respond_to do |format|
      #   format.turbo_stream
      # end
    end
  end

  private

  def store_guest_token
    cookies.permanent.signed[:guest_token] = params[:token] if params[:token]
  end
end
