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
    @shop_name = @trade_in_request.shop.titleize

    mail(
      to: @trade_in_request.email,
      from: @store.mail_from_address,
      subject: "#{t('.subject')}#{@trade_in_request.with_promo ? " - #{@trade_in_request.coupon_code}" : ''}"
    )
  end
end
