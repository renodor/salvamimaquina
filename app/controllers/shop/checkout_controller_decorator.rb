# frozen_string_literal: true

module Shop::CheckoutControllerDecorator
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

  Spree::CheckoutController.prepend self
end
