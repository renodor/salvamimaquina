# frozen_string_literal: true

class RepairShoprApi::V1::SyncProduct < RepairShoprApi::V1::Base
  class << self
    def call(sync_logs:, attributes: nil, repair_shopr_id: nil)
      # Fetch product attributes from RepairShopr,
      # or take the one given as an argument
      attributes ||= get_product(repair_shopr_id)

      raise ArgumentError, 'attributes or id is needed' unless attributes

      Rails.logger.info("Start to sync product with RepairShopr ID: #{attributes['id']}")
      Spree::Variant.transaction do
        existing_variant = Spree::Variant.find_by(repair_shopr_id: attributes['id'])
        add_product_attributes_from_notes(attributes) if attributes['notes'].present?

        # If variant needs to be assigned to a new product,
        # we need to destroy it, because there is currently no way to assign an existing variant to another product in Solidus.
        # And we need to continue the syncing process in order to create the new variant and assign it to its new product
        destroy_variant_and_destroy_product_if_it_has_no_other_variants(existing_variant) if existing_variant && variant_needs_to_be_assigned_to_new_product?(existing_variant, attributes)

        # Nulify @variant_options if there are no options, otherwise it may be memoized from previous products and apply wrong options
        @variant_options = attributes['variant_options'].present? ? create_variant_options(attributes['variant_options']) : nil

        initialize_product_and_variant(attributes)

        assign_product_attributes(attributes)
        assign_variant_attributes(attributes)

        update_product_stock(attributes['location_quantities'])
        update_product_classifications(attributes['product_category'], attributes['brand'])

        RepairShoprApi::V1::SyncProductImages.call(attributes: attributes, sync_logs: sync_logs) unless variant_needs_to_be_excluded?(attributes)
      end
      sync_logs.synced_products += 1
      Rails.logger.info("Product with RepairShopr ID: #{attributes['id']} synced")

      @variant
    rescue ActiveRecord::ActiveRecordError => e
      sync_logs.sync_errors << { product_repair_shopr_id: attributes['id'], error: e }
      false
    rescue RepairShoprApi::V1::Base::NotFoundError
      sync_logs.sync_errors << { error: "Couldn't find product with id: #{repair_shopr_id}" }
      false
    rescue => e
      sync_logs.sync_errors << { error: e.message }
      false
    end

    private

    # If variant is disabled or does not belong to the "ecom" product category
    # It means it needs to be excluded from solidus
    def variant_needs_to_be_excluded?(attributes)
      attributes['disabled'] || !attributes['product_category']&.include?(RepairShoprApi::V1::Base::RS_ROOT_CATEGORY_NAME)
    end

    # If a variant goes from one model to another (The current model name is different from the syncing model name),
    # or if it is removed from a model (The syncing variant does not have model, but the current variant is not the master variant)
    # It means this variant needs to be assigned to a new product
    def variant_needs_to_be_assigned_to_new_product?(variant, attributes)
      (attributes['model'] && variant.product.name != attributes['model']) || (attributes['model'].blank? && !variant.is_master?)
    end

    def destroy_variant_and_destroy_product_if_it_has_no_other_variants(variant)
      product = variant.product
      variant.destroy!
      product.destroy! unless product.has_variants?
    end

    def initialize_product_and_variant(attributes)
      if attributes['model']
        @product = Spree::Product.find_or_initialize_by(name: attributes['model'])
        @variant = Spree::Variant.find_or_initialize_by(repair_shopr_id: attributes['id'])
      else
        @product = Spree::Variant.find_by(repair_shopr_id: attributes['id'])&.product || Spree::Product.new
        @product.name = attributes['name']

        @variant = @product.master
        @variant.repair_shopr_id = attributes['id']
      end
    end

    def assign_product_attributes(attributes)
      if @product.new_record?
        @product.available_on = Date.today
        @product.shipping_category_id = Spree::ShippingCategory.find_by(name: 'Default').id

        # Spree::Product.master needs a price for Spree::Product to be valid, so we have to put one here
        # however, if there are several variants, this master price will never really be used
        @product.master.price = price_before_tax(attributes['price_retail'])
      end

      @product.assign_attributes(
        description: attributes['description'],
        meta_description: "#{@product.name} - #{attributes['description']}",
      )

      # Add Spree::OptionTypes to product
      @product.option_types = @variant_options ? @variant_options[:option_types] : []

      @product.save!
    end

    def assign_variant_attributes(attributes)
      @variant.assign_attributes(
        repair_shopr_name: attributes['name'],
        product_id: @product.id,
        is_master: attributes['model'].blank?,
        sku: attributes['upc_code'] || '',
        cost_price: attributes['price_cost'],
        weight: attributes['weight'],
        width: attributes['width'],
        height: attributes['height'],
        depth: attributes['depth']
      )

      # Add Spree::OptionValues to variant
      @variant.option_values = @variant_options ? @variant_options[:option_values] : []
      @variant.price = price_before_tax(attributes['price_retail'])

      @variant.save!
    end

    # Location quantities is a RepairShopr array with the product stock information on each store
    # Spree::StockLocation instances are the Solidus equivalent of RepairShopr stores
    # StockItem instances are Solidus way to track product inventory in different stock locations
    # (since we have two stock locations, each product will have 2 stock items)
    def update_product_stock(location_quantities)
      location_quantities.each do |location_quantity|
        stock_location = Spree::StockLocation.find_by!(repair_shopr_id: location_quantity['location_id'])
        stock_item = @variant.stock_items.find_by!(stock_location: stock_location)
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
    def update_product_classifications(product_category, brand)
      taxon_name = product_category == RepairShoprApi::V1::Base::RS_ROOT_CATEGORY_NAME ? 'Categories' : product_category.split(';').last
      taxon = Spree::Taxon.find_by!(name: taxon_name, taxonomy_id: Spree::Taxonomy.find_by!(name: 'Categories').id) # TODO: memoize "Categories" taxonomy id
      Spree::Classification.find_or_initialize_by(product_id: @variant.product.id).update!(taxon_id: taxon.id)

      return unless brand

      brand_taxonomy = Spree::Taxonomy.find_by!(name: 'Brands')
      brand_parent_taxon = brand_taxonomy.taxons.find_by(parent_id: nil)
      taxon = Spree::Taxon.find_or_create_by!(name: brand, taxonomy_id: brand_taxonomy.id, parent_id: brand_parent_taxon.id) # TODO: memoize "Brand" taxonomy id
      Spree::Classification.find_or_initialize_by(product_id: @variant.product.id).update!(taxon_id: taxon.id)
    end

    # Convert the product notes comming from RS into a Ruby hash
    # and merge this hash with the product attributes
    # (We use these product notes to pass additional product attributes not natively supported by RS)
    def add_product_attributes_from_notes(attributes)
      attributes['variant_options'] = {}
      attributes['notes'].split("\r\n").map do |attribute|
        attribute_array = attribute.split(':')
        attribute_type = attribute_array[0].strip
        attribute_value = attribute_array[1].strip

        if %w[model brand weight height width depth].include?(attribute_type)
          attributes[attribute_type] = attribute_value
        else
          attributes['variant_options'][attribute_type] = attribute_value
        end
      end
    end

    # Find or create Spree::OptionType, it will then be associated to Spree::Product
    # Find or create Spree::OptionValue, it will then be associated to Spree::Variant
    def create_variant_options(variant_options)
      options = { option_types: [], option_values: [] }

      variant_options.each do |variant_option_type, variant_option_value|
        option_type = Spree::OptionType.find_or_create_by!(
          name: variant_option_type,
          presentation: variant_option_type
        )

        option_value = Spree::OptionValue.find_or_create_by!(
          option_type_id: option_type.id,
          name: variant_option_value,
          presentation: variant_option_value
        )

        options[:option_types] << option_type
        options[:option_values] << option_value
      end

      options
    end

    # Simple helper method to deduce ITBMS from taxed price and find te price before tax
    # We need to deduce the tax from the retail price to show product prices without tax on the shop, and add tax only at checkout
    def price_before_tax(retail_price)
      retail_price - ((retail_price / 1.07) * 0.07)
    end
  end
end
