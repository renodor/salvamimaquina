# frozen_string_literal:true

class AdminNotificationMailer < ApplicationMailer
  def invoice_error_message(order:)
    @order = order
    @ship_address = @order.ship_address
    mail(
      to: 'administracion@salvamimaquina.com',
      from: 'administracion@salvamimaquina.com',
      subject: 'www.salvamimaquina.com - Invoice ERROR'
    )
  end

  def payment_error_message(invoice:)
    @invoice = invoice
    mail(
      to: 'administracion@salvamimaquina.com',
      from: 'administracion@salvamimaquina.com',
      subject: 'www.salvamimaquina.com - Payment ERROR'
    )
  end
end
