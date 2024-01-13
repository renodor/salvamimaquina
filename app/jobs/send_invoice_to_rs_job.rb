# frozen_string_literal: true

class SendInvoiceToRsJob < ApplicationJob
  queue_as :default

  def perform(order)
    RepairShoprApi::V1::CreateInvoice.call(order)
  end
end
