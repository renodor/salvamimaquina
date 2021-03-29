# frozen_string_literal: true

class RepairShoprApi::V1::SyncProduct < RepairShoprApi::V1::Base
  class << self
    def call(attributes: nil, repair_shopr_id: nil, sync_logs: nil)
      attributes ||= get_product(repair_shopr_id)['product']

      raise ArgumentError, 'attributes or id is needed' unless attributes

      Rails.logger.info("Start to sync product with RepairShopr ID: #{attributes['id']}")
      product = nil
      Spree::Product.transaction do
        if attributes['disabled']
          sync_logs&.deleted_products += 1 if Spree::Product.find_by(repair_shopr_id: attributes['id'])&.destroy!
          return
        end

        product = create_or_update_product(attributes)
        update_product_stock(product, attributes['location_quantities'])
        update_product_classifications(product, attributes['product_category'])
      end
      sync_logs&.synced_products += 1
      Rails.logger.info("Product with RepairShopr ID: #{attributes['id']} synced")

      product
    rescue => e
      sync_logs.sync_errors << { product_repair_shopr_id: attributes['id'], error: e }
      false
    end

    def create_or_update_product(attributes)
      product = Spree::Product.find_or_initialize_by(repair_shopr_id: attributes['id'])

      # attributes at a Spree::Product level
      product.attributes = {
        description: attributes['description'],
        name: attributes['name']
      }

      # attributes at Spree::Variant level
      product.master.attributes = {
        sku: attributes['upc_code'] || '',
        cost_price: attributes['price_cost']
      }

      # attributes at a Spree::Price level
      product.price = attributes['price_retail']

      if product.new_record?
        product.available_on = Date.today if product.new_record?
        product.shipping_category_id = Spree::ShippingCategory.find_by(name: 'Default').id
      end

      product.save!
      product
    end

    def update_product_stock(product, location_quantities)
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
    end

    def update_product_classifications(product, product_category)
      product.classifications.destroy_all
      return unless product_category

      taxon = Spree::Taxon.find_by(name: product_category.split(';').last, taxonomy_id: Spree::Taxonomy.find_by(name: 'Categories').id)
      Spree::Classification.create!(product_id: product.id, taxon_id: taxon.id)
    end
  end
end
