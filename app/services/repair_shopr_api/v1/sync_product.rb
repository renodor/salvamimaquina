# frozen_string_literal: true

class RepairShoprApi::V1::SyncProduct < RepairShoprApi::V1::Base
  class << self
    def call(sync_logs:, attributes: nil, repair_shopr_id: nil)
      # Fetch product attributes from RepairShopr,
      # or take the one given as an argument
      attributes ||= get_product(repair_shopr_id)

      raise ArgumentError, 'attributes or id is needed' unless attributes

      Rails.logger.info("Start to sync product with RepairShopr ID: #{attributes['id']}")
      Spree::Product.transaction do
        # If product is disabled on RepairShopr, or does not belong to the "ecom" product category,
        # we just delete it from Solidus database
        if attributes['disabled'] || !attributes['product_category']&.include?(RepairShoprApi::V1::Base::RS_ROOT_CATEGORY_NAME)
          sync_logs.deleted_products += 1 if Spree::Product.find_by(repair_shopr_id: attributes['id'])&.destroy!
          return
        end

        create_or_update_product(attributes)
        update_product_stock(attributes['location_quantities'])
        update_product_classifications(attributes['product_category'])
      end
      sync_logs.synced_products += 1
      Rails.logger.info("Product with RepairShopr ID: #{attributes['id']} synced")

      RepairShoprApi::V1::SyncProductImages.call(attributes: attributes, sync_logs: sync_logs)

      @product
    rescue ActiveRecord::ActiveRecordError => e
      sync_logs.sync_errors << { product_repair_shopr_id: attributes['id'], error: e }
      false
    rescue RepairShoprApi::V1::Base::NotFoundError
      sync_logs.sync_errors << { error: "Couldn't find product with id: #{repair_shopr_id}" }
      false
    end

    # Create/update product, product variant and product price
    def create_or_update_product(attributes)
      @product = Spree::Product.find_or_initialize_by(repair_shopr_id: attributes['id'])

      # Set attributes at a Spree::Product level
      @product.attributes = {
        description: attributes['description'],
        name: attributes['name']
      }

      # Set attributes at Spree::Variant level
      @product.master.attributes = {
        sku: attributes['upc_code'] || '',
        cost_price: attributes['price_cost']
      }

      # Set attributes at a Spree::Price level
      # We need to deduce the tax from the retail price
      # (To show product prices without tax on the shop, and add tax only at checkout)
      price_before_tax = attributes['price_retail'] - ((attributes['price_retail'] / 1.07) * 0.07)
      @product.price = price_before_tax

      if @product.new_record?
        @product.available_on = Date.today
        @product.shipping_category_id = Spree::ShippingCategory.find_by(name: 'Default').id
      end

      @product.save!
    end

    # Location quantities is a RepairShopr array with the product stock information on each store
    # Spree::StockLocation instances are the Solidus equivalent of RepairShopr stores
    # StockItem instances are Solidus way to track product inventory in different stock locations
    # (since we have two stock locations, each product will have 2 stock items)
    def update_product_stock(location_quantities)
      location_quantities.each do |location_quantity|
        stock_location = Spree::StockLocation.find_by!(repair_shopr_id: location_quantity['location_id'])
        stock_item = @product.stock_items.find_by!(stock_location: stock_location)
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
    # If the product belong to a specific product category on RepairShopr, we make sure it belongs to the correct taxon in Solidus (through classification)
    # If the product belong the root category "ecom" on RepairShopr, we put it under the root taxon "Categories" on Solidus
    # (In RepairShopr a product can belong to only one product category, so to only one classification in Solidus)
    def update_product_classifications(product_category)
      taxon_name = product_category == RepairShoprApi::V1::Base::RS_ROOT_CATEGORY_NAME ? 'Categories' : product_category.split(';').last
      taxon = Spree::Taxon.find_by!(name: taxon_name, taxonomy_id: Spree::Taxonomy.find_by!(name: 'Categories').id) # TODO: memoize "Categories" taxonomy id
      Spree::Classification.find_or_initialize_by(product_id: @product.id).update!(taxon_id: taxon.id)
    end
  end
end
