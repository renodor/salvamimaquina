# frozen_string_literal: true

# This is somewhat contrary to standard REST convention since there is not
# actually a Checkout object. There's enough distinct logic specific to
# checkout which has nothing to do with updating an order that this approach
# is warranted.
class CheckoutsController < CheckoutBaseController
  before_action :ensure_valid_state
  before_action :ensure_valid_payment
  before_action :check_registration
  before_action :setup_for_current_state

  # Updates the order and advances to the next state (when possible.)
  def update
    if update_order

      assign_temp_address

      if @order.payments.present? && params[:payment_source]
        payment = @order.payments.last

        @html_form_3ds = payment.sale(params[:payment_source][payment.payment_method_id.to_s])
        if @html_form_3ds
          render :three_d_secure, layout: 'empty_layout'
          return
        end
      end

      order_transition_and_completion_logic

    else
      render :edit
    end
  end

  def three_d_secure_response
    @payment.process_3ds_response(JSON.parse(params[:Response]))
    order_transition_and_completion_logic
  end

  private

  def order_transition_and_completion_logic
    unless transition_forward
      redirect_on_failure
      return
    end

    if @order.completed?
      finalize_order
    else
      send_to_next_state
    end
  end

  def update_order
    Spree::OrderUpdateAttributes.new(@order, update_params, request_env: request.headers.env).apply
  end

  def assign_temp_address
    @order.temporary_address = !params[:save_user_address]
  end

  # When there is an error with payment we don't want to display the specific payment gateway error that can be not comprehensible by the user
  # So we just display the flash message with a generic "payment gateway" error, to indicate something went wrong with payment
  def redirect_on_failure
    flash[:error] = @order.state == 'payment' ? t('spree.spree_gateway_error_flash_for_checkout') : @order.errors.full_messages.join("\n")
    redirect_to(checkout_state_path(@order.state))
  end

  def transition_forward
    if @order.can_complete?
      @order.complete
    else
      @order.next
    end
  end

  def finalize_order
    @current_order = nil
    set_successful_flash_notice
    redirect_to completion_route
  end

  def set_successful_flash_notice
    flash.notice = t('spree.order_processed_successfully')
    flash['order_completed'] = true
  end

  def send_to_next_state
    redirect_to checkout_state_path(@order.state)
  end

  def update_params
    case params[:state].to_sym
    when :address
      # We won't do a billing/shipping address distinction
      # Users will only fill one address (shipping), which will automatically be set as the billing address as well
      params[:order][:bill_address_attributes] = params[:order][:ship_address_attributes]

      massaged_params.require(:order).permit(
        permitted_checkout_address_attributes
      )
    when :delivery
      equalize_shipments_shipping_methods if @order.shipments.size == 2

      massaged_params.require(:order).permit(
        permitted_checkout_delivery_attributes
      )
    when :payment
      if @order.covered_by_store_credit?
        massaged_params.fetch(:order, {})
      else
        massaged_params.require(:order)
      end.permit(
        permitted_checkout_payment_attributes
      )
    else
      massaged_params.fetch(:order, {}).permit(
        permitted_checkout_confirm_attributes
      )
    end
  end

  def massaged_params
    massaged_params = params.deep_dup

    move_payment_source_into_payments_attributes(massaged_params)
    move_wallet_payment_source_id_into_payments_attributes(massaged_params)
    set_payment_parameters_amount(massaged_params, @order)

    massaged_params
  end

  def ensure_valid_state
    return if skip_state_validation?
    return if @order.has_checkout_step?(params[:state] || @order.state)

    @order.state = 'cart'
    redirect_to checkout_state_path(@order.checkout_steps.first)
  end

  def ensure_valid_payment
    # Fix for https://github.com/spree/spree/issues/4117
    # If confirmation of payment fails, redirect back to payment screen
    return unless params[:state] == "confirm"
    return unless @order.payment_required?

    if @order.payments.valid.empty?
      flash.keep
      redirect_to checkout_state_path("payment")
    end
  end

  def setup_for_current_state
    method_name = :"before_#{@order.state}"
    send(method_name) if respond_to?(method_name, true)
  end

  def before_address
    gon.mapbox_api_key = Rails.application.credentials.mapbox_api_key
    @order.assign_default_user_addresses
    # If the user has a default address, the previous method call takes care
    # of setting that; but if he doesn't, we need to build an empty one here
    @order.bill_address ||= Spree::Address.build_default
    @order.ship_address ||= Spree::Address.build_default if @order.checkout_steps.include?('delivery')

    # Set Panama as a default state and default city
    @order.ship_address.state ||= Spree::State.find_by(name: 'Panamá')
    @order.ship_address.city ||= 'Panamá'
  end

  def before_delivery
    return if params[:order].present?

    packages = @order.shipments.includes(:stock_location, shipping_rates: %i[shipping_method taxes]).map(&:to_package)
    @differentiator = Spree::Stock::Differentiator.new(@order, packages)
    @delivery_in_first_or_second_zone = @order.shipments.first.shipping_rates.any? do |shipping_rate|
      shipping_rate.shipping_method.service_level == 'delivery' && [1, 2].include?(shipping_rate.shipping_method.code.to_i)
    end
    @free_shipping_threshold = Spree::Promotion::FREE_SHIPPING_THRESHOLD
  end

  def before_payment
    return unless @order.checkout_steps.include? 'delivery'

    packages = @order.shipments.includes(:stock_location).map(&:to_package)
    @differentiator = Spree::Stock::Differentiator.new(@order, packages)
    @differentiator.missing.each do |variant, quantity|
      @order.contents.remove(variant, quantity)
    end

    # Will be needed if we want user to be able to save payment methods
    # if spree_current_user && spree_current_user.respond_to?(:wallet)
    #   @wallet_payment_sources = spree_current_user.wallet.wallet_payment_sources
    #   @default_wallet_payment_source = @wallet_payment_sources.detect(&:default) ||
    #                                    @wallet_payment_sources.first
    # end
  end

  def order_params
    params.fetch(:order, {}).permit(:email)
  end

  # HACK: We can't remove `skip_state_validation?` as of now because it is
  # stubbed in some system tests.
  def skip_state_validation?
    false
  end

  # Introduces a registration step whenever the +registration_step+ preference is true.
  def check_registration
    return unless registration_required?

    store_location
    redirect_to new_checkout_session_path
  end

  def registration_required?
    Spree::Auth::Config[:registration_step] &&
      !already_registered?
  end

  def already_registered?
    spree_current_user || guest_authenticated?
  end

  def guest_authenticated?
    current_order&.email.present? &&
      Spree::Config[:allow_guest_checkout]
  end

  # Overrides the equivalent method defined in Spree::Core.  This variation of the method will ensure that users
  # are redirected to the tokenized order url unless authenticated as a registered user.
  def completion_route
    return order_path(@order) if spree_current_user

    token_order_path(@order, @order.guest_token)
  end

  # If the order have splitted packages (products shipped from Bella Vista and others from San Francisco), we don't want the user to see it and pay 2 shippings.
  # So on front end we are displaying only the first package, and user will choose the shipping method of the first package only.
  # In this method we make sure that, if there are 2 packages, the second one will have the same shipping method than the first one.
  # (Because otherwise 2nd package will always have a default shipping method)
  def equalize_shipments_shipping_methods
    shipment_attributes = params[:order][:shipments_attributes]
    first_shipment_shipping_method_id = Spree::ShippingRate.find(shipment_attributes['0'][:selected_shipping_rate_id]).shipping_method.id
    second_shipment_corresponding_shipping_rate_id = Spree::Shipment.find(shipment_attributes['1'][:id]).shipping_rates.find_by(shipping_method_id: first_shipment_shipping_method_id).id
    shipment_attributes['1'][:selected_shipping_rate_id] = second_shipment_corresponding_shipping_rate_id
  end
end
