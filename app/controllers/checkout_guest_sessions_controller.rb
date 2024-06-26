# frozen_string_literal: true

class CheckoutGuestSessionsController < CheckoutBaseController
  def create
    if params[:order][:email] =~ Devise.email_regexp && current_order.update(email: params[:order][:email])
      redirect_to checkout_path
    else
      flash[:registration_error] = t('spree.email_is_invalid')
      @user = Spree::User.new
      render template: 'checkout_sessions/new', status: :unprocessable_entity
    end
  end
end
