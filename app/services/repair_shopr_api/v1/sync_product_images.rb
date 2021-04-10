# frozen_string_literal: true

class RepairShoprApi::V1::SyncProductImages < RepairShoprApi::V1::Base
  class << self
    def call(sync_logs:, attributes: nil, repair_shopr_id: nil)
      # Fetch product attributes from RepairShopr,
      # or take the one given as an argument
      attributes ||= get_product(repair_shopr_id)['product']

      raise ArgumentError, 'attributes or id is needed' unless attributes

      # The product we want to sync images for must exist on the first place
      @product = Spree::Product.find_by!(repair_shopr_id: attributes['id'])
      product_photos = attributes['photos']
      product_image_ids = []
      Rails.logger.info("Start to sync product photos for product with RepairShopr ID: #{attributes['id']}")
      product_photos.each do |photo|
        # Don't update an already existing photo
        if (existing_product_image = @product.images.find_by(repair_shopr_id: photo['id']))
          product_image_ids << existing_product_image
          sync_logs.synced_product_images += 1
          next
        end

        # Create product image and store its id in the product_image_ids array
        # We use this array later to spot product images that need to be deleted
        product_image_id = create_product_image(photo)
        product_image_ids << product_image_id
        sync_logs.synced_product_images += 1
      rescue => e
        sync_logs.sync_errors << { product_image_repair_shopr_id: photo['id'], error: e.message }
      end

      # All product images with an id not present in the product_images_ids array need to be deleted
      # (Because it means they have been deleted from RepairShopr)
      deleted_product_images = @product.images.where.not(id: product_image_ids).destroy_all
      sync_logs.deleted_product_images += deleted_product_images.size
      Rails.logger.info("Product photos of product with RepairShopr ID: #{attributes['id']} synced")

      @product.images
    rescue => e
      sync_logs.sync_errors << { product_images_error: e.message }
      false
    end

    # Create the product image (it is an Active Storage attachment)
    def create_product_image(photo)
      image = @product.images.new(
        viewable_type: 'Spree::Variant',
        viewable_id: @product.master.id,
        repair_shopr_id: photo['id'],
        alt: @product.name
      )
      image.attachment.attach(io: URI.parse(photo['photo_url']).open, filename: "#{@product.slug}-#{@product.master.sku}")
      image.save!
      image.id
    end
  end
end
