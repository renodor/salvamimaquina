# frozen_string_literal:true

module Spree
  module OrderMailerDecorator
    def confirm_email(order, resend = false) # rubocop:disable Style/OptionalBooleanParameter
      @order = order
      @address = @order.ship_address
      @store = @order.store
      I18n.with_locale('es-MX') do # Currently forcing emails in Spanish (we don't want the locale to change regarding user browser's language)
        subject = build_subject(t('.subject'), resend)
        mail(to: @order.email, bcc: bcc_address(@store), from: from_address(@store), subject: subject)
      end
    end

    private

    def build_subject(subject_text, resend)
      resend_text = (resend ? "[#{t('spree.resend').upcase}] " : '')
      "#{resend_text}#{@order.store.name} - #{subject_text} ##{@order.number}"
    end

    Spree::OrderMailer.prepend self
  end
end
