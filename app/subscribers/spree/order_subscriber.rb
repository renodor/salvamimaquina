# frozen_string_literal: true

# https://guides.solidus.io/developers/events/overview.html
module Spree
  module OrderSubscriber
    include Spree::Event::Subscriber

    event_action :order_finalized

    # This event will be fired every time an order is finalized
    def order_finalized(event)
      order = event.payload[:order]
      SendInvoiceToRsJob.perform_later(order)
      OrderMailer.confirm_email(order, false, true).deliver_later # Send email order confirmation
      UpdateProductPurchaseCountJob.perform_later(order)
    end
  end
end
