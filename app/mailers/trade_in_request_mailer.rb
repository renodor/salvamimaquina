# frozen_string_literal:true

class TradeInRequestMailer < ApplicationMailer
  helper 'svg'
  helper 'cloudinary_links_with_folders'

  def confirmation_email(trade_in_request)
    @trade_in_request = trade_in_request
    @variant = @trade_in_request.variant
    @coupon_validity = TradeInRequest::COUPON_VALIDITY_DAYS
    @coupon_validity_text = "#{@coupon_validity} #{I18n.t('day', count: @coupon_validity).downcase}"
    @store = Spree::Store.default

    mail(
      to: @trade_in_request.email,
      from: @store.mail_from_address,
      subject: "#{t('.subject')}#{@trade_in_request.with_promo ? " - #{@trade_in_request.coupon_code}" : ''}"
    )
  end

  def admin_confirmation_email(trade_in_request)
    @trade_in_request = trade_in_request
    @variant = @trade_in_request.variant
    @coupon_validity = TradeInRequest::COUPON_VALIDITY_DAYS
    @store = Spree::Store.default

    mail(to: @store.mail_from_address, from: @store.mail_from_address, subject: 'New trade-in request from www.salvamimaquina.com')
  end
end
