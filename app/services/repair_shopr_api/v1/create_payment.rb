# frozen_string_literal: true

class RepairShoprApi::V1::CreatePayment < RepairShoprApi::V1::Base
  class << self
    def call(invoice)
      payment = {
        amount_cents: invoice['total'].to_f * 100,
        invoice_id: invoice['id'],
        applied_at: invoice['date'],
        payment_method: 'Credit Card',
        customer_id: invoice['customer_id']
      }

      post_payments(payment)
      # TODO: send notif/error/email/anything... if payment is not correctly created on RS...
    end
  end
end
