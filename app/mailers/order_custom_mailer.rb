# frozen_string_literal:true

class OrderCustomMailer < Spree::BaseMailer
  helper 'cloudinary_links_with_folders'

  def confirm_email(order, for_admin: false)
    @order = order
    @address = @order.ship_address
    @store = @order.store
    @for_admin = for_admin

    if @for_admin
      mail(
        to: @store.mail_from_address,
        from: @store.mail_from_address,
        subject: "#{t('spree.order_custom_mailer.confirm_email.new_ecommerce_order')} - #{@order.number}"
      )
    else
      mail(
        to: @order.email,
        bcc: bcc_address(@store),
        from: @store.mail_from_address,
        subject: "#{@order.store.name} - #{t('spree.order_custom_mailer.confirm_email.subject')} ##{@order.number}"
      )
    end
  end

  def cancel_email(order, resend = false)
    @order = order
    @store = @order.store
    subject = build_subject(t('.subject'), resend)

    mail(to: @order.email, from: from_address(@store), subject: subject)
  end

  def inventory_cancellation_email(order, inventory_units, resend = false)
    @order, @inventory_units = order, inventory_units
    @store = @order.store
    subject = build_subject(t('spree.order_mailer.inventory_cancellation.subject'), resend)

    mail(to: @order.email, from: from_address(@store), subject: subject)
  end
  
  private

  def build_subject(subject_text, resend)
    resend_text = (resend ? "[#{t('spree.resend').upcase}] " : '')
    "#{resend_text}#{@order.store.name} #{subject_text} ##{@order.number}"
  end
end
