# frozen_string_literal: true

class RepairShoprApi::V1::Product < RepairShoprApi::V1::Base
  class << self
    def call(id)
      product_attributes = get_product(id)['product']

      Spree::Product.transaction do
        product = create_or_update_product(product_attributes)
        update_product_stock(product, product_attributes['location_quantities'])
        update_product_classifications(product, product_attributes['product_category'])
      end
    end

    def create_or_update_product(attributes)
      Rails.logger.info("Updating product with RepairShopr ID: #{attributes['id']}")

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
      Rails.logger.info("Product with RepairShopr ID: #{attributes['id']} updated")
      product
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

    def update_product_classifications(product, product_category)
      product.classifications.destroy_all
      taxon = Spree::Taxon.find_by(name: product_category.split(';').last, taxonomy_id: Spree::Taxonomy.find_by(name: 'Categories').id)
      Spree::Classification.create!(product_id: product.id, taxon_id: taxon.id)
    end
  end
end
