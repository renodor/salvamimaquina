# frozen_string_literal: true

module Spree
  module OrderDecorator
    def self.prepended(base)
      base.insert_checkout_step :three_d_secure, after: :payment
      base.remove_checkout_step :confirm
    end

    # def process_payments_before_complete
    #   return if !payment_required?

    #   if payments.valid.empty?
    #     errors.add(:base, I18n.t('spree.no_payment_found'))
    #     return false
    #   end

    #   if process_payments!
    #     true
    #   else
    #     saved_errors = errors[:base]
    #     payment_failed!
    #     saved_errors.each { |error| errors.add(:base, error) }
    #     false
    #   end
    # end

    # def process_payments_with(method_name)
    #   # Don't run if there is nothing to pay.
    #   return true if payment_total >= total

    #   unprocessed_payments.each do |payment|
    #     break if payment_total >= total

    #     # response = payment.public_send(method_name)
    #     # return response if payment.processing? && payment.source.needs_3ds?
    #     payment.public_send(method_name)
    #   end
    # rescue Core::GatewayError => error
    #   result = !!Spree::Config[:allow_checkout_on_gateway_error]
    #   errors.add(:base, error.message) && (return result)
    # end

    Spree::Order.prepend self
  end
end
