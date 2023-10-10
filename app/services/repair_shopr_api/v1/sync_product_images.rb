# frozen_string_literal: true

class RepairShoprApi::V1::SyncProductImages < RepairShoprApi::V1::Base
  class << self
    def call(sync_logs:, attributes: nil, repair_shopr_id: nil)
      # Fetch product attributes from RepairShopr,
      # or take the one given as an argument
      attributes ||= get_product(repair_shopr_id)['product']

      raise ArgumentError, 'attributes or id is needed' unless attributes

      # The product we want to sync images for must exist on the first place
      @variant = Spree::Variant.find_by!(repair_shopr_id: attributes['id'])
      photos = attributes['photos']
      photo_ids = []
      Rails.logger.info("Start to sync product photos for product with RepairShopr ID: #{attributes['id']}")
      photos.each do |photo|
        # Store photo id. We will use it later to identify photo that need to be destroyed
        photo_ids << photo['id']

        # Don't update an already existing photo
        if @variant.images.find_by(repair_shopr_id: photo['id'])
          sync_logs.synced_product_images += 1
          next
        end

        # Create product image and store its id in the product_image_ids array
        # We use this array later to identify product images that need to be deleted
        create_product_image(photo)
        sync_logs.synced_product_images += 1
      rescue => e # rubocop:disable Style/RescueStandardError
        sync_logs.sync_errors << { product_image_repair_shopr_id: photo['id'], error: e.message }
      end

      # All product images of this same variant with an id not present in the photo_ids array need to be deleted
      # (Because it means they have been deleted from RepairShopr)
      deleted_product_images = @variant.images.where.not(repair_shopr_id: photo_ids).destroy_all
      sync_logs.deleted_product_images += deleted_product_images.size
      Rails.logger.info("Product photos of product with RepairShopr ID: #{attributes['id']} synced")

      @variant.images
    rescue => e # rubocop:disable Style/RescueStandardError
      sync_logs.sync_errors << { product_images_error: e.message }
      false
    ensure
      sync_logs.save!
      Sentry.capture_message(name, { extra: { sync_logs_errors: sync_logs.sync_errors } }) if sync_logs.sync_errors.any?
    end

    # Create the product image (it is an Active Storage attachment)
    def create_product_image(photo)
      image = Spree::Image.new(
        viewable_type: 'Spree::Variant',
        viewable_id: @variant.id,
        repair_shopr_id: photo['id'],
        alt: @variant.name
      )
      image.attachment.attach(io: URI.parse(photo['photo_url']).open, filename: "#{@variant.product.slug}-#{@variant.repair_shopr_id}")
      image.save!
    end
  end
end
