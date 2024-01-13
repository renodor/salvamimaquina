# frozen_string_literal:true

class AdminNotificationMailer < Spree::BaseMailer
  ADMIN_EMAIL = Spree::Store.default.mail_from_address

  def user_message_email(user_message)
    @user_message = user_message
    mail(
      to: ADMIN_EMAIL,
      from: ADMIN_EMAIL,
      subject: 'New Message from salvamimaquina.com contact form'
    )
  end

  def corporate_message_email(corporate_message)
    @corporate_message = corporate_message
    mail(
      to: [ADMIN_EMAIL, 'quentin@salvamimaquina.com'].join(', '),
      from: ADMIN_EMAIL,
      subject: 'New message from salvamimaquina.com corporate client contact form'
    )
  end

  def invoice_error_email(order)
    @order = order
    @ship_address = @order.ship_address
    mail(
      to: ADMIN_EMAIL,
      from: ADMIN_EMAIL,
      subject: 'www.salvamimaquina.com - Invoice ERROR'
    )
  end

  def payment_error_email(invoice)
    @invoice = invoice
    mail(
      to: ADMIN_EMAIL,
      from: ADMIN_EMAIL,
      subject: 'www.salvamimaquina.com - Payment ERROR'
    )
  end

  def reparation_request_email(reparation_request)
    @reparation_request = reparation_request
    mail(
      to: ADMIN_EMAIL,
      from: ADMIN_EMAIL,
      subject: 'New reparation request from www.salvamimaquina.com'
    )
  end

  def trade_in_request_email(trade_in_request)
    @trade_in_request = trade_in_request
    @variant = @trade_in_request.variant
    @coupon_validity = TradeInRequest::COUPON_VALIDITY_DAYS
    @store = Spree::Store.default

    mail(
      to: ADMIN_EMAIL,
      from: ADMIN_EMAIL,
      subject: 'New trade-in request from www.salvamimaquina.com'
    )
  end
end