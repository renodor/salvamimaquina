# frozen_string_literal: true

class RepairShoprApi::V1::CreateInvoice < RepairShoprApi::V1::Base
  class << self
    def call(order)
      user_id = me['user_id'] # Todo: store this somewhere in an ENV variable... No need to call API if it won't change

      customer_id = get_customer_by_email(order.email)['id']
      customer_info = {
        email: order.email,
        first_name: order.bill_address.firstname,
        last_name: order.bill_address.lastname,
        fullname: order.bill_address.name,
        address: order.bill_address.address1,
        address_2: order.bill_address.address2,
        city: order.bill_address.city,
        state: order.bill_address.state.name,
        phone: order.bill_address.phone
      }

      if customer_id
        update_customer(customer_id, customer_info)
      else
        customer_info[:referred_by] = 'ecom'
        customer_id = create_customer(customer_info)
      end

      repair_shopr_invoice = {
        customer_id: customer_id,
        balance_due: order.total,
        number: order.number,
        date: order.completed_at,
        subtotal: order.item_total,
        total: order.total,
        tax: order.additional_tax_total,
        is_paid: order.payment_state == 'paid',
        # location_id: TBD ??
        line_items: []
      }

      order.line_items.each do |line_item|
        repair_shopr_invoice[:line_items] << {
          item: line_item.variant.name,
          name: line_item.variant.description,
          product_id: line_item.product.repair_shopr_id,
          quantity: line_item.quantity,
          price: line_item.price * 1.07,
          taxable: true,
          upc_code: line_item.variant.sku,
          tax_rate_id: line_item.tax_category.repair_shopr_id,
          user_id: user_id
        }
      end

      invoice = post_invoices(repair_shopr_invoice)
      # Todo: send notif/error/email/anything... if invoice is not correctly created on RS...
    end
  end
end
