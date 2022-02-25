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
    rescue RepairShoprApi::V1::Base::BadRequestError, RepairShoprApi::V1::Base::UnprocessableEntityError, RepairShoprApi::V1::Base::NotFoundError => e
      # Rescue RepairShoprApi client error response because thise class is called from a background job,
      # and we don't want sidekiq to retry the job if its failing because of a client error,
      # otherwise it could create an unlimited number of RepairShopr (wrong) payments...
      # But we make sure that we properly notify admins of what is happening
      Sentry.capture_exception(
        e,
        {
          extra: {
            info: 'Error creating a RepairShopr payment',
            invoice: invoice,
            payment: payment
          }
        }
      )
      AdminNotificationMailer.payment_error_email(invoice).deliver_later
    end
  end
end
