# frozen_string_literal: true

class StoreController < Spree::BaseController
  include Spree::Core::ControllerHelpers::Pricing
  include Spree::Core::ControllerHelpers::Order
  include Taxonomies

  layout 'storefront'

  def unauthorized
    render 'shared/auth/unauthorized', layout: Spree::Config[:layout], status: 401
  end

  def cart_link
    render partial: 'shared/cart/link_to_cart'
    fresh_when(current_order, template: 'shared/cart/_link_to_cart')
  end

  def set_user_language
    # available_locales = Spree.i18n_available_locales
    # locale = [
    #   params[:locale],
    #   session[set_user_language_locale_key],
    #   (config_locale if respond_to?(:config_locale, true)),
    #   I18n.default_locale
    # ].detect do |candidate|
    #   candidate &&
    #     available_locales.include?(candidate.to_sym)
    # end
    # session[set_user_language_locale_key] = locale
    # I18n.locale = locale
    # Carmen.i18n_backend.locale = locale

    # Don't do complexe logic to set user language, just set the I18n.default_locale
    I18n.locale = I18n.default_locale
  end

  private

  def config_locale
    I18n.locale
  end

  def lock_order
    Spree::OrderMutex.with_lock!(@order) { yield } # rubocop:disable Style/ExplicitBlockArgument
  rescue Spree::OrderMutex::LockFailed
    flash[:error] = t('spree.order_mutex_error')
    redirect_to cart_path
  end
end
