# frozen_string_literal: true

module Spree
  module CheckoutControllerDecorator
    def transition_forward
      tokenize_credit_card(params[:payment_source]) if @order.state == 'payment' && @order.credit_cards.present?

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

    def tokenize_credit_card(payment_source)
      credit_card_info = payment_source.values.first
      payment_method = Spree::PaymentMethod.find(payment_source.keys.first.to_i)
      token = payment_method.tokenize(
        card_number: credit_card_info[:number].delete(' '),
        customer_reference: @order.email, # This customer reference is used by FAC and should be unique per customer (card holder)
        expiry_date: credit_card_info[:expiry].delete(' / ')
      )

      @order.credit_cards.first.update!(
        token: token,
        cvv: credit_card_info[:verification_value]
      )

      binding.pry
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
    def load_order
      gon.mapbox_api_key = Rails.application.credentials.mapbox_api_key
      @order = current_order
      redirect_to(spree.cart_path) && return unless @order
    end

    Spree::CheckoutController.prepend self
  end
end
