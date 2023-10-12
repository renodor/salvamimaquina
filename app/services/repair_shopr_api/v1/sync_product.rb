# frozen_string_literal: true

class RepairShoprApi::V1::SyncProduct < RepairShoprApi::V1::Base
  class << self
    def call(sync_logs:, attributes:)
      Rails.logger.info("Start to sync product with RepairShopr ID: #{attributes['id']}")

      add_product_attributes_from_notes(attributes) if attributes['notes'].present?
      create_product_and_variant(attributes)
      update_product_stock(attributes['location_quantities'])
      create_taxons(attributes['product_category'])
      update_product_classifications(attributes['product_category'].split(';').last)
      sync_variant_images(attributes['photos'], sync_logs)

      sync_logs.synced_products += 1

      Rails.logger.info("Product with RepairShopr ID: #{attributes['id']} synced")

      @variant
    rescue => e # rubocop:disable Style/RescueStandardError
      sync_logs.sync_errors << { product_repair_shopr_id: attributes['id'], error: e }
      false
    ensure
      sync_logs.save!
      Sentry.capture_message(name, { extra: { sync_logs_errors: sync_logs.sync_errors } }) if sync_logs.sync_errors.any?
    end

    private

    # Convert the product notes comming from RS into a Ruby hash
    # and merge this hash with the product attributes
    # (We use these product notes to pass additional product attributes not natively supported by RS)
    def add_product_attributes_from_notes(attributes)
      attributes['variant_options'] = {}
      attributes['notes'].split(/\r\n|\n/).reject(&:blank?).map do |attribute|
        match = attribute.match(/(?<type>.+)[:=](?<value>.+)/)
        attribute_type = match[:type].strip.downcase
        attribute_value = match[:value].strip

        attribute_value.downcase! unless %w[model parent_product].include?(attribute_type)

        if %w[parent_product brand highlight].include?(attribute_type)
          attributes[attribute_type] = attribute_value
        else
          attributes['variant_options'][attribute_type] = attribute_value
        end
      end
    end

    def create_product_and_variant(attributes)
      @variant = Spree::Variant.find_or_initialize_by(repair_shopr_id: attributes['id'])
      old_product = @variant.product # Save to maybe delete later

      if attributes['parent_product'].present?
        @product = Spree::Product.find_or_initialize_by(name: attributes['parent_product'])
      else
        @product = @variant.product || Spree::Product.new

        # Edge case where we need to set a new master variant to a persisted product
        # (When parent_product is removed from an existing product)
        if @product.persisted? && @variant != @product.master
          @product.master.update!(deleted_at: Date.current, is_master: false)
          @product.reload
        end

        @product.master = @variant
        @product.name = attributes['name'].strip
      end

      if @product.new_record?
        @product.available_on = Date.today
        @product.shipping_category_id = Spree::ShippingCategory.find_by(name: 'Default').id # TODO: memoize that

        # Spree::Product.master needs a price for Spree::Product to be valid, so we have to put one here
        # however, if there are several variants, this master price will never really be used
        @product.master.prices << Spree::Price.new(amount: price_before_tax(attributes['price_retail']), currency: 'USD')
      end

      @product.assign_attributes(
        description: attributes['description'],
        meta_description: "#{@product.name} - #{attributes['description']}",
        highlight: attributes['highlight'].present?
      )

      variant_options = create_variant_options(attributes['variant_options'].presence || [])

      # Add Spree::OptionTypes to product
      @product.option_types = variant_options[:option_types]
      @product.save!

      @variant.assign_attributes(
        repair_shopr_name: attributes['name'].strip,
        product_id: @product.id,
        is_master: attributes['parent_product'].blank?,
        sku: attributes['upc_code'] || '',
        cost_price: attributes['price_cost'],
        condition: attributes['condition'].match('refurbished')&.to_s || 'original'
      )

      # Add Spree::OptionValues to variant
      @variant.option_values = variant_options[:option_values]
      @variant.price = price_before_tax(attributes['price_retail'])
      @variant.save!

      # If @variant has been assigned to a new product, and old product doesn't have any other variants, we can destroy it
      old_product.destroy! if old_product != @product && old_product&.variants&.empty?
    end

    # Location quantities is a RepairShopr array with the product stock information on each store
    # Spree::StockLocation instances are the Solidus equivalent of RepairShopr stores
    # StockItem instances are Solidus way to track product inventory in different stock locations
    # (since we have two stock locations, each product will have 2 stock items)
    def update_product_stock(location_quantities)
      location_quantities.each do |location_quantity|
        stock_location = Spree::StockLocation.find_by!(repair_shopr_id: location_quantity['location_id']) # TODO: memoize that?
        stock_item = @variant.stock_items.find_by!(stock_location: stock_location)
        next if stock_item.count_on_hand == location_quantity['quantity']

        stock_item.set_count_on_hand(location_quantity['quantity'])
      end
    end

    def create_taxons(product_category_names)
      categories_taxonomy = Spree::Taxonomy.find_by!(name: 'Categories') # TODO: memoize "Categories" taxonomy id
      parent_taxon = categories_taxonomy.taxons.root # TODO: memoize root taxon

      product_category_names.split(';').reject { |cat| cat == self::RS_ROOT_CATEGORY_NAME }.each do |product_category_name|
        taxon = categories_taxonomy.taxons.find_or_initialize_by(name: product_category_name)
        taxon.update!(parent: parent_taxon) if taxon.parent != parent_taxon
        parent_taxon = taxon
      end
    end

    # Spree::Classification is the joining table between Spree::Product and Spree::Taxons
    def update_product_classifications(product_category_name)
      @product.classifications.destroy_all # Easier to destroy and recreate all classifications... TODO: Maybe a way to improve that

      # Currently the only Taxonomy we have is Categories (So all products are first of all, classified by category)
      # If the product belong to a specific product category on RepairShopr, we make sure it belongs to the correct taxon in Solidus (through classification)
      # If the product belong the root category "ecom" on RepairShopr, we put it under the root taxon "Categories" on Solidus
      categories_taxonomy = Spree::Taxonomy.find_by!(name: 'Categories') # TODO: memoize "Categories" taxonomy id
      Spree::Classification.create!(
        product: @product,
        taxon: categories_taxonomy.taxons.find_by(name: product_category_name) || categories_taxonomy.taxons.root
      )
    end

    # Find or create Spree::OptionType, it will then be associated to Spree::Product
    # Find or create Spree::OptionValue, it will then be associated to Spree::Variant
    def create_variant_options(variant_options)
      options = { option_types: [], option_values: [] }

      variant_options.each do |variant_option_type, variant_option_value|
        option_type = Spree::OptionType.find_or_initialize_by(
          name: variant_option_type,
          presentation: variant_option_type
        )

        option_type.position = 1 if option_type.name == 'color' && option_type.position != 1
        option_type.save!

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

    def sync_variant_images(photos, sync_logs)
      photos.each do |photo|
        # Don't update an already existing photo
        unless @variant.images.find_by(repair_shopr_id: photo['id'])
          image = Spree::Image.new(
            viewable_type: 'Spree::Variant',
            viewable_id: @variant.id,
            repair_shopr_id: photo['id'],
            alt: @variant.name
          )
          image.attachment.attach(io: URI.parse(photo['photo_url']).open, filename: "#{@variant.product.slug}-#{@variant.repair_shopr_id}")
          image.save!
        end

        sync_logs.synced_product_images += 1
      rescue => e # rubocop:disable Style/RescueStandardError
        sync_logs.sync_errors << { product_image_repair_shopr_id: photo['id'], error: e.message }
      end

      # All product images of this same variant with an id not present in the photo_ids array need to be deleted
      # (Because it means they have been deleted from RepairShopr)
      deleted_product_images = @variant.images.where.not(repair_shopr_id: photos.map { |photo| photo['id'] }).destroy_all
      sync_logs.deleted_product_images += deleted_product_images.size
    end
  end
end
