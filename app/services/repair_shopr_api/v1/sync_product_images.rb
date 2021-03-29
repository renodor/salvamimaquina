# frozen_string_literal: true

class RepairShoprApi::V1::SyncProductImages < RepairShoprApi::V1::Base
  class << self
    def call(attributes: nil, repair_shopr_id: nil, sync_logs: nil)
      attributes ||= get_product(repair_shopr_id)['product']

      raise ArgumentError, 'attributes or id is needed' unless attributes

      @product = Spree::Product.find_by!(repair_shopr_id: attributes['id'])
      product_photos = attributes['photos']
      product_image_ids = []
      Rails.logger.info("Start to sync product photos for product with RepairShopr ID: #{attributes['id']}")
      product_photos.each do |photo|
        if (existing_product_image = @product.images.find_by(repair_shopr_id: photo['id']))
          product_image_ids << existing_product_image
          next
        end

        product_image_id = create_product_image(photo)
        product_image_ids << product_image_id
        sync_logs&.synced_product_images += 1
      rescue => e
        sync_logs.sync_errors << { product_image_repair_shopr_id: photo['id'], error: e.message }
      end
      deleted_product_images = @product.images.where.not(id: product_image_ids).destroy_all
      sync_logs&.deleted_product_images += deleted_product_images.size
      Rails.logger.info("Product photos of product with RepairShopr ID: #{attributes['id']} synced")

      @product.images
    rescue => e
      sync_logs.sync_errors << { product_images_error: e.message }
      false
    end

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
