# frozen_string_literal: true

module Spree
  module OrderSubscriber
    include Spree::Event::Subscriber

    event_action :order_finalized

    def order_finalized(event)
      RepairShoprApi::V1::CreateInvoice.call(event.payload[:order])
    end
  end
end
