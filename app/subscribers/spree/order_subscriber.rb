# frozen_string_literal: true

# https://guides.solidus.io/developers/events/overview.html
module Spree
  module OrderSubscriber
    include Spree::Event::Subscriber

    event_action :order_finalized

    # This event will be fired every time an order is finalized
    def order_finalized(event)
      RepairShoprApi::V1::CreateInvoice.call(event.payload[:order])
    end
  end
end
