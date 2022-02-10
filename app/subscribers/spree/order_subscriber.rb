# frozen_string_literal: true

# https://guides.solidus.io/developers/events/overview.html
module Spree
  module OrderSubscriber
    include Spree::Event::Subscriber

    event_action :order_finalized

    # This event will be fired every time an order is finalized
    def order_finalized(event)
      order = event.payload[:order]
      SendInvoiceToRsJob.perform_later(order) if Rails.env.production?
      OrderMailer.confirm_email(order, false, true).deliver_later # Send order confirmation to the admin (administracion@salvamimaquina.com)
      UpdateProductPurchaseCountJob.perform_later(order)
    end
  end
end
