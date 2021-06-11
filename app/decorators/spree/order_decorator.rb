# frozen_string_literal: true

module Spree
  module OrderDecorator
    def self.prepended(base)
      base.remove_checkout_step :confirm
    end

    private

    def process_payments_before_complete
      return unless payment_required?

      # Because we am messing up with normal Order state machine we need to add this condition
      # It happens if the authorize3Ds request does not succeed. The Spree::Payment::Processing module is still not reach,
      # So we fallback in this method with a failed payment
      if payment_state == 'failed'
        errors.add(:base, I18n.t('spree.payment_processing_failed'))
        return false
      elsif payments.valid.empty?
        errors.add(:base, I18n.t('spree.no_payment_found'))
        return false
      end

      process_payments! ? true : false
    end

    Spree::Order.prepend self
  end
end
