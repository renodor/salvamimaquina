# frozen_string_literal: true

class RepairShoprApi::V1::SyncProductImages < RepairShoprApi::V1::Base
  class << self
    def call(attributes: nil, repair_shopr_id: nil)
      attributes ||= get_product(repair_shopr_id)['product']

      raise ArgumentError, 'attributes or id is needed' unless attributes

      @product = Spree::Product.find_by!(repair_shopr_id: attributes['id'])
      product_photos = attributes['photos']
      Rails.logger.info("Start to sync product photos for product with RepairShopr ID: #{attributes['id']}")
      product_photos.each do |photo|
        Spree::Image.transaction do
          next if @product.images.find_by(repair_shopr_id: photo['id'])

          create_product_image(photo)
        end
      end
      delete_removed_product_images(product_photos.map { |product_photo| product_photo['id'] })
      Rails.logger.info("Product photos of product with RepairShopr ID: #{attributes['id']} synced")
    end

    def create_product_image(photo)
      image = @product.images.new(viewable_type: 'Spree::Variant', viewable_id: @product.master.id, repair_shopr_id: photo['id'], alt: @product.name)
      image.attachment.attach(io: URI.parse(photo['photo_url']).open, filename: "#{@product.slug}-#{@product.master.sku}")
      image.save!
    end

    def delete_removed_product_images(product_photo_ids)
      @product.images.all.each do |image|
        image.destroy! unless product_photo_ids.include?(image.repair_shopr_id)
      end
    end
  end
end
