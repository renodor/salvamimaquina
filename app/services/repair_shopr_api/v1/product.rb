# frozen_string_literal: true

class RepairShoprApi::V1::Product < RepairShoprApi::V1::Base

  TEST_PAYLOAD = {
      "id" => 2,
      "price_cost" => 20.4,
      "price_retail" => 152.43,
      "condition" => "",
      "description" => "C'est le, c'est le, c'est le proproooooo du démon!!!",
      "maintain_stock" => true,
      "name" => "Produit du Démon",
      "quantity" => 0,
      "warranty" => nil,
      "sort_order" => nil,
      "reorder_at" => 4,
      "disabled" => false,
      "taxable" => true,
      "product_category" => "Default;Hardware;iPhone",
      "category_path" => "Default;Hardware;iPhone",
      "upc_code" => "AA12345",
      "discount_percent" => nil,
      "warranty_template_id" => nil,
      "qb_item_id" => nil,
      "desired_stock_level" => 4,
      "price_wholesale" => 0,
      "notes" => "",
      "tax_rate_id" => 39011,
      "physical_location" => "",
      "serialized" => false,
      "vendor_ids" => [],
      "long_description" => nil,
      "location_quantities" => [
        {
          "id" => 4473603,
          "product_id" => 4079926,
          "location_id" => 1927,
          "quantity" => 3,
          "tax_rate_id" => nil,
          "created_at" => "2018-10-01T11:39:50.682-05:00",
          "updated_at" => "2021-02-09T14:24:57.815-05:00",
          "reorder_at" => 4,
          "desired_stock_level" => 4,
          "price_cost_cents" => nil,
          "price_retail_cents" => nil
        },
        {
          "id" => 4474545,
          "product_id" => 4079926,
          "location_id" => 1928,
          "quantity" => 12,
          "tax_rate_id" => nil,
          "created_at" => "2018-10-01T11:40:23.074-05:00",
          "updated_at" => "2021-03-02T10:41:35.852-05:00",
          "reorder_at" => 4,
          "desired_stock_level" => 4,
          "price_cost_cents" => nil,
          "price_retail_cents" => nil
        }
      ],
      "photos" => []
    }

  class << self
    def call(id)
      # attributes = get_product(id)['product']
      attributes = TEST_PAYLOAD
      Spree::Product.transaction do
        product = create_or_update_product(attributes)
        update_product_stock(product, attributes['location_quantities'])
        update_product_categories(product, attributes['product_category'])
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

    def update_product_categories(product, product_category)
      categories_array = product_category.split(';')

      # repair_shopr_product_categories = get_product_categories['categories']

      ### SYNC RS CATEGORIES WITH SOLIDUS CATEGORY TAXONS ###
      repair_shopr_product_categories = [
        {
          "id" => 455441,
          "account_id" => 59355,
          "ancestry" => nil,
          "name" => "Default",
          "description" => nil,
          "device_product_id" => nil,
          "names_depth_cache" => "Default"
        },
        {
          "id" => 455443,
          "account_id" => 59355,
          "ancestry" => "455441",
          "name" => "Hardware",
          "description" => nil,
          "device_product_id" => nil,
          "names_depth_cache" => "Default;Hardware"
        },
        {
          "id" => 455442,
          "account_id" => 59355,
          "ancestry" => "455441",
          "name" => "Labor",
          "description" => nil,
          "device_product_id" => nil,
          "names_depth_cache" => "Default;Labor"
        },
        {
          "id" => 455444,
          "account_id" => 59355,
          "ancestry" => "455441/455442",
          "name" => "iPhone",
          "description" => nil,
          "device_product_id" => nil,
          "names_depth_cache" => "Default;Labor;iPhone"
        }
      ]

      categories_taxon = Spree::Taxon.find_by(name: 'Categories')
      repair_shopr_product_categories.each do |repair_shopr_product_category|
        taxon = find_or_create_taxon(repair_shopr_product_category)
        if (parent_category_id = repair_shopr_product_category['ancestry']&.split('/')&.last)
          parent_category_attributes = repair_shopr_product_categories.find { |category| category['id'] == parent_category_id }
          parent_taxon = find_or_create_taxon(parent_category_attributes)
          taxon.move_to_child_of(parent_taxon)
        else
          taxon.move_to_child_of(categories_taxon)
        end
      end
      # delete solidus taxons not present in array
      ### END OF SYNC RS CATEGORIES WITH SOLIDUS CATEGORY TAXONS ###

      ### UPDATE PRODUCT CATEGORIES
    end

    def find_or_create_taxon(product_category)
      categories_taxonomy_id = Spree::Taxonomy.find_by(name: 'Categories').id
      taxon = Spree::Taxon.find_or_initialize_by(repair_shopr_id: product_category['id'], taxonomy_id: categories_taxonomy_id)
      taxon.name = product_category['name']
      taxon.description = product_category['description']
      taxon.save!
      taxon
    end
  end
end
