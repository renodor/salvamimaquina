# frozen_string_literal: true

class RepairShoprApi::V1::CreateInvoice < RepairShoprApi::V1::Base
  class << self
    def call(order)
      @order = order
      @user_id = me['user_id'] # TODO: store this somewhere in an ENV variable... No need to call API if it won't change

      @repair_shopr_customer_id = create_or_update_repair_shopr_customer
      repair_shopr_invoice = build_repair_shopr_invoice
      repair_shopr_invoice[:line_items] = build_repair_shopr_line_items
      repair_shopr_invoice[:line_items] << build_repair_shopr_shipping
      repair_shopr_invoice[:line_items] << build_repair_shopr_promotions

      invoice = post_invoices(repair_shopr_invoice)['invoice']
      # TODO: send notif/error/email/anything... if invoice is not correctly created on RS...

      # RepairShopr will take line item prices with ITBMS and calculate the price without taxes from that and then re-calculate the price with ITBMS...
      # During this calcul some cents could be added or removed from the order sub-total (because of roundup...)
      # So we could end up with a RepairShopr invoice with a different total than the Solidus order total...
      # In that case we need to add a new "adjustment" line items to RepairShopr invoice to equalize both totals
      total_order = order.total
      total_invoice = invoice['total'].to_d
      if total_order != total_invoice
        absolute_difference = (total_order - total_invoice).abs
        invoice_adjustment = total_order > total_invoice ? absolute_difference : -absolute_difference
        post_line_items(invoice['id'], build_repair_shopr_adjustment_line_items(invoice_adjustment))
        invoice['total'] = (total_invoice + invoice_adjustment).to_s
      end

      RepairShoprApi::V1::CreatePayment.call(invoice)
    end

    def create_or_update_repair_shopr_customer
      ship_address = @order.ship_address
      customer_info = {
        email: @order.email,
        firstname: ship_address.firstname,
        lastname: ship_address.lastname,
        fullname: ship_address.name,
        address: ship_address.address1,
        address_2: ship_address.address2,
        city: "#{ship_address.district.name} - #{ship_address.city}",
        state: ship_address.state.name,
        phone: ship_address.phone,
        notes: ship_address.google_maps_link,
        disabled: false
      }

      if (repair_shopr_customer = get_customer_by_email(@order.email))
        update_customer(repair_shopr_customer['id'], customer_info)
      else
        customer_info[:referred_by] = 'ecom'
        repair_shopr_customer = create_customer(customer_info)
      end

      repair_shopr_customer['id']
    end

    def build_repair_shopr_invoice
      {
        customer_id: @repair_shopr_customer_id,
        balance_due: @order.total,
        number: @order.number,
        date: @order.completed_at,
        subtotal: @order.item_total,
        total: @order.total,
        tax: @order.additional_tax_total,
        is_paid: @order.payment_state == 'paid',
        location_id: define_invoice_location_id(@order.shipments),
        note: "Sold from Ecommerce Website. To deliver to: #{@order.ship_address.google_maps_link}"
      }
    end

    def build_repair_shopr_line_items
      @order.line_items.map do |line_item|
        {
          item: line_item.variant.name,
          name: line_item.variant.description,
          product_id: line_item.variant.repair_shopr_id,
          quantity: line_item.quantity,
          price: line_item.variant.price * 1.07,
          taxable: true,
          upc_code: line_item.variant.sku,
          tax_rate_id: line_item.tax_category.repair_shopr_id,
          user_id: @user_id
        }
      end
    end

    def build_repair_shopr_shipping
      {
        item: 'Shipping',
        name: 'Costo de entrega',
        quantity: 1,
        taxable: false,
        price: @order.shipment_total
      }
    end

    def build_repair_shopr_promotions
      {
        item: 'Promotions',
        name: @order.promotions.map(&:name).join(', '),
        quantity: 1,
        taxable: false,
        price: @order.promo_total
      }
    end

    def build_repair_shopr_adjustment_line_items(adjustment)
      {
        item: 'Adjustment',
        name: 'Ajuste calculo ITBMS',
        quantity: 1,
        taxable: false,
        price: adjustment
      }
    end

    # Bella Vista id = 1928
    # San Francisco id = 1927
    # Check the quantity of items by location
    # Set the invoice location to the location that has more items
    # If both locations have the same item quantities, set the invoice location to Bella Vista
    def define_invoice_location_id(shipments)
      stock_location_repair_shopr_ids = Hash.new(0)
      shipments.each do |shipment|
        stock_location_repair_shopr_ids[shipment.stock_location.repair_shopr_id] += shipment.line_items.map(&:quantity).sum
      end

      return 1928 if stock_location_repair_shopr_ids[1928] == stock_location_repair_shopr_ids[1927]

      stock_location_repair_shopr_ids.max_by { |_, qty| qty }[0]
    end
  end
end
