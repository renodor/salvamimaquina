# frozen_string_literal: true

class RepairShoprApi::V1::SyncProduct < RepairShoprApi::V1::Base
  class << self
    def call(attributes: nil, repair_shopr_id: nil, sync_logs:)
      # Fetch product attributes from RepairShopr,
      # or take the one given as an argument
      attributes ||= get_product(repair_shopr_id)['product']

      raise ArgumentError, 'attributes or id is needed' unless attributes

      Rails.logger.info("Start to sync product with RepairShopr ID: #{attributes['id']}")
      product = nil
      Spree::Product.transaction do
        # If product is disabled on RepairShopr, we just delete it from Solidus database
        if attributes['disabled']
          sync_logs.deleted_products += 1 if Spree::Product.find_by(repair_shopr_id: attributes['id'])&.destroy!
          return
        end

        @product = create_or_update_product(attributes)
        update_product_stock(attributes['location_quantities'])
        update_product_classifications(attributes['product_category'])
      end
      sync_logs.synced_products += 1
      Rails.logger.info("Product with RepairShopr ID: #{attributes['id']} synced")

      @product
    rescue => e
      sync_logs.sync_errors << { product_repair_shopr_id: attributes['id'], error: e }
      false
    end

    # Create/update product, product variant and product price
    def create_or_update_product(attributes)
      product = Spree::Product.find_or_initialize_by(repair_shopr_id: attributes['id'])

      # Set attributes at a Spree::Product level
      product.attributes = {
        description: attributes['description'],
        name: attributes['name']
      }

      # Set attributes at Spree::Variant level
      product.master.attributes = {
        sku: attributes['upc_code'] || '',
        cost_price: attributes['price_cost']
      }

      # Set attributes at a Spree::Price level
      product.price = attributes['price_retail']

      if product.new_record?
        product.available_on = Date.today
        product.shipping_category_id = Spree::ShippingCategory.find_by(name: 'Default').id
      end

      product.save!
      product
    end

    # Location quantities is a RepairShopr array with the product stock information on each store
    # Spree::StockLocation instances are the Solidus equivalent of RepairShopr stores
    # StockItem instances are Solidus way to track product inventory in different stock locations
    # (since we have two stock locations, each product will have 2 stock items)
    def update_product_stock(location_quantities)
      location_quantities.each do |location_quantity|
        stock_location = Spree::StockLocation.find_by!(repair_shopr_id: location_quantity['location_id'])
        stock_item = @product.stock_items.find_by(stock_location: stock_location)
        next unless stock_item.count_on_hand != location_quantity['quantity']

        absolute_difference = (stock_item.count_on_hand - location_quantity['quantity']).abs

        # To change product stock in Solidus you need to create Spree::StockMovement instances
        Spree::StockMovement.create!(
          stock_item_id: stock_item.id,
          originator_type: self,
          quantity: stock_item.count_on_hand > location_quantity['quantity'] ? -absolute_difference : absolute_difference
        )
      end
    end

    # Spree::Classification is the joining table between Spree::Product and Spree::Taxons
    # If the product belong to one product category on RepairShopr, we make sure it belongs to the correct taxon in Solidus (through classification)
    # If not, we just delete any existing classifications for this product
    # (In RepairShopr a product can belong to only one product category, so to only one classification in Solidus)
    def update_product_classifications(product_category)
      if product_category
        taxon = Spree::Taxon.find_by!(name: product_category.split(';').last, taxonomy_id: Spree::Taxonomy.find_by!(name: 'Categories').id)
        Spree::Classification.find_or_initialize_by(product_id: @product.id).update!(taxon_id: taxon.id)
      else
        @product.classifications.destroy_all
      end
    end
  end
end
