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
        return if @order.payments.present? && authorize_3ds # TODO: what to do if authorize_3ds fail?

        transition_and_complete_order_logic

      else
        render :edit
      end
    end

    def transition_and_complete_order_logic
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

    # TODO: this logic should be inside a PaymentController or 3ds Controller
    def three_d_secure_response
      payment = @order.payments.last
      response = payment.payment_method.handle_authorize_3ds_response(params)

      # TODO: improve this logic, maybe don't need to use transition_forward and finalize_order_if_completed methods...
      # Maybe just check the logic myself (@order.complete then finalize_order)
      # But need to check all possible cases scenarios and redirect on failures (if transition can't go forward, if payment can't be captured, if order is not completed etc...)
      transition_and_complete_order_logic if response.success?
      # TODO: add else statement with payment failure error and redirect to checkout payment step
    end

    private

    # TODO: remove from here (I didn't modified it from original solidus code base, it is here FYI)
    def transition_forward
      if @order.can_complete?
        @order.complete
      else
        @order.next
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
      @order.assign_default_user_addresses
      # If the user has a default address, the previous method call takes care
      # of setting that; but if he doesn't, we need to build an empty one here
      @order.bill_address ||= Spree::Address.build_default
      @order.ship_address ||= Spree::Address.build_default if @order.checkout_steps.include?('delivery')

      # Set Panama as a default state and default city
      @order.ship_address.state ||= Spree::State.find_by(name: 'Panamá')
      @order.ship_address.city ||= 'Panamá'
    end

    # The only reason to monkey patch this method is because it is in a before_action callback applied to all method,
    # So we use it to pass mapbox_api_key to JS via gon
    # TODO: pass it only to needed steps...
    def load_order
      gon.mapbox_api_key = Rails.application.credentials.mapbox_api_key
      @order = current_order
      redirect_to(spree.cart_path) && return unless @order
    end

    # TODO: this logic should be inside a PaymentController or 3ds Controller
    def authorize_3ds
      payment = @order.payments.last
      response = payment.payment_method.authorize_3ds(
        amount: @order.total,
        source: params[:payment_source][payment.payment_method_id.to_s],
        order_number: "#{@order.number}-#{payment.number}"
      )

      if response.success?
        @html_form_3ds = response.params['html_form']
        render :three_d_secure, layout: 'empty_layout'
        true
      else
        false
      end
    end

    Spree::CheckoutController.prepend self
  end
end
