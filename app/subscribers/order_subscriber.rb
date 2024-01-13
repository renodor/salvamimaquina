# frozen_string_literal: true

# https://guides.solidus.io/customization/subscribing-to-events
class OrderSubscriber
  include Omnes::Subscriber

  # This event will be fired every time an order is finalized
  handle :order_finalized, with: :post_purchase_actions, id: :order_finalized_event

  def post_purchase_actions(event)
    order = event.payload[:order]
    SendInvoiceToRsJob.perform_later(order)
    OrderCustomMailer.confirm_email(order, for_admin: true).deliver_later # Send email order confirmation
    UpdateProductPurchaseCountJob.perform_later(order)
  end
end
