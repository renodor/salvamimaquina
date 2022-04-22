# frozen_string_literal: true

module Spree
  module CheckoutControllerDecorator
    def self.prepended(base)
      base.skip_before_action :verify_authenticity_token, only: :three_d_secure_response
    end

    # Updates the order and advances to the next state (when possible.)
    def update
      if update_order

        assign_temp_address

        if @order.payments.present? && params[:payment_source]
          payment = @order.payments.last
          return if payment.source.needs_3ds? && authorize_3ds(payment)

          payment.authorize(params[:payment_source][payment.payment_method_id.to_s])
        end

        order_transition_and_completion_logic

      else
        render :edit
      end
    end

    def three_d_secure_response
      Rails.logger.debug('-------- DEBUG LOGS')
      Rails.logger.debug("FOUND PAYMENT ID: #{params[:OrderID].split('-').last}")
      Rails.logger.debug("ORDER NUMBER: #{@order.number}")
      Rails.logger.debug("ORDER PAYMENT NUMBERS: #{@order.payments.map(&:number)}")
      Rails.logger.debug('DEBUG LOGS --------')
      @order.payments.find_by(number: params[:OrderID].split('-').last).process_3ds_response(params)
      order_transition_and_completion_logic
    end

    private

    # When there is an error with payment we don't want to display the specific payment gateway error that can be not comprehensible by the user
    # So we just display the flash message with a generic "payment gateway" error, to indicate something went wrong with payment
    def redirect_on_failure
      flash[:error] = @order.state == 'payment' ? t('spree.spree_gateway_error_flash_for_checkout') : @order.errors.full_messages.join("\n")
      redirect_to(checkout_state_path(@order.state))
    end

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
        massaged_params.require(:order).permit(
          permitted_checkout_payment_attributes
        )
      else
        massaged_params.fetch(:order, {}).permit(
          permitted_checkout_confirm_attributes
        )
      end
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

    # Includes needed relations to avoid N+1
    def before_delivery
      return if params[:order].present?

      packages = @order.shipments.includes(:stock_location, shipping_rates: %i[shipping_method taxes]).map(&:to_package)
      @differentiator = Spree::Stock::Differentiator.new(@order, packages)
      @delivery_in_first_or_second_zone = @order.shipments.first.shipping_rates.any? do |shipping_rate|
        shipping_rate.shipping_method.service_level == 'delivery' && [1, 2].include?(shipping_rate.shipping_method.code.to_i)
      end
      @free_shipping_threshold = Spree::Promotion::FREE_SHIPPING_THRESHOLD
    end

    # Includes needed relations to avoid N+1
    def before_payment
      return unless @order.checkout_steps.include? 'delivery'

      packages = @order.shipments.includes(:stock_location).map(&:to_package)
      @differentiator = Spree::Stock::Differentiator.new(@order, packages)
      @differentiator.missing.each do |variant, quantity|
        @order.contents.remove(variant, quantity)
      end

      # Will be needed if we want user to be able to save payment methods
      # if try_spree_current_user.respond_to?(:wallet)
      #   @wallet_payment_sources = try_spree_current_user.wallet.wallet_payment_sources
      #   @default_wallet_payment_source = @wallet_payment_sources.detect(&:default) ||
      #                                    @wallet_payment_sources.first
      # end
    end

    def authorize_3ds(payment)
      @html_form_3ds = payment.authorize_3ds(params[:payment_source][payment.payment_method_id.to_s])
      if @html_form_3ds
        render :three_d_secure, layout: 'empty_layout'
        true
      else
        false
      end
    end

    # redirect_to instead of only render
    # Because otherwise we render :edit but we are still in the #update method that has no corresponding route...
    # So if user refresh page it causes a 404 error
    # Another consequence is that @order.errors are lost during the redirect, which is actually what we want
    # Indeed we want the flash message with a generic "payment gateway" error, to indicate something went wrong with payment,
    # but we don't want to display the specific payment gateway error that can be not comprehensible by the user
    def rescue_from_spree_gateway_error(exception)
      flash[:error] = t('spree.spree_gateway_error_flash_for_checkout')
      @order.errors.add(:base, exception.message)
      redirect_to checkout_state_path(@order.state)
    end

    def load_order
      @order = current_order
      # Add an aditional net safety to find the @order if it can't be find with the cookie
      # (It could happend when coming back from 3DS, the cookie may be lost between redirects, (even if it shouldn't...))
      @order ||= Spree::Order.find_by(number: params[:OrderID]&.split('-')&.first)
      redirect_to(spree.cart_path) && return unless @order
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

    # Provides a route to redirect after order completion
    def completion_route
      spree.orders_es_mx_path(@order)
    end

    Spree::CheckoutController.prepend self
  end
end
