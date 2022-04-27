# frozen_string_literal:true

module Spree
  module OrderMailerDecorator
    def self.prepended(base)
      base.helper 'cloudinary_links_with_folders'
    end

    def confirm_email(order, resend = false, for_admin = false) # rubocop:disable Style/OptionalBooleanParameter
      @order = order
      @address = @order.ship_address
      @store = @order.store
      @for_admin = for_admin

      if @for_admin
        mail(to: @store.mail_from_address, from: @store.mail_from_address, subject: "#{t('.new_ecommerce_order')} - #{@order.number}")
      else
        mail(to: @order.email, bcc: bcc_address(@store), from: @store.mail_from_address, subject: build_subject(t('.subject'), resend))
      end
    end

    Spree::OrderMailer.prepend self
  end
end
