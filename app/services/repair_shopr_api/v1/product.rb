# frozen_string_literal: true

class RepairShoprApi::V1::Product < RepairShoprApi::V1::Base
  class << self
    def update_product(id)
      attributes = get_product(id)['product']
      Rails.logger.info("Updating product with RepairShopr ID: #{id}")

      product = Spree::Product.find_or_initialize_by(repair_shopr_id: attributes['id'])
      # attributes at a Spree::Product level
      product.attributes = {
        description: attributes['description'],
        name: attributes['name'],
        discontinue_on: attributes['disabled'] ? Date.today : nil
      }

      # attributes at Spree::Variant level
      product.master.attributes = {
        sku: attributes['upc_code'],
        cost_price: attributes['price_cost']
      }

      # attributes at a Spree::Price level
      product.price = attributes['price_retail']

      if product.new_record?
        product.available_on = Date.today if product.new_record?
        product.shipping_category_id = Spree::ShippingCategory.find_by(name: 'Default').id
      end
      product.save!
      Rails.logger.info("Product with RepairShopr ID: #{id} updated")
      update_product_stock(product, attributes['location_quantities'])
    end

    def update_product_stock(product, location_quantities)
      Rails.logger.info("Updating stock of product with RepairShopr ID: #{product.repair_shopr_id}")
      location_quantities.each do |location_quantity|
        stock_location = Spree::StockLocation.find_by!(repair_shopr_id: location_quantity['location_id'])
        stock_item = product.stock_items.find_by(stock_location: stock_location)
        next unless stock_item.count_on_hand != location_quantity['quantity']

        absolute_difference = (stock_item.count_on_hand - location_quantity['quantity']).abs

        Spree::StockMovement.create!(
          stock_item_id: stock_item.id,
          originator_type: self,
          quantity: stock_item.count_on_hand > location_quantity['quantity'] ? -absolute_difference : absolute_difference
        )
      end
      Rails.logger.info("Stock of product with RepairShopr ID: #{product.repair_shopr_id} updated")
    end
  end
end