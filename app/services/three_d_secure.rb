# frozen_string_literal: true

class ThreeDSecure
  def self.authorize(order, source)
    payment = order.payments.last
    payment.payment_method.authorize_3ds(
      amount: order.total,
      source: source,
      order_number: "#{order.number}-#{payment.number}"
    )
  end

  def self.response(payment, authorize_response)
    payment.payment_method.handle_authorize_3ds_response(authorize_response)
  end
end
