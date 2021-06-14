# frozen_string_literal: true

class RepairShoprApi::V1::SyncProducts < RepairShoprApi::V1::Base
  class << self
    def call(sync_logs:)
      Rails.logger.info('Start to sync products')

      products = get_products
      # Sync all products
      products.each do |product|
        RepairShoprApi::V1::SyncProduct.call(attributes: product, sync_logs: sync_logs)
      end

      # Destroy products that are on Solidus but where not fetched on RepairShopr
      # (They were probably disabled on RepairShoper, or removed from the ecom category)
      variants_to_destroy = Spree::Variant.where.not(repair_shopr_id: products.map { |product| product['id'] })
                                          .or(Spree::Variant.where(repair_shopr_id: nil))
      variants_to_destroy.each do |variant|
        product = variant.product
        variant.destroy!
        product.destroy! unless product.has_variants?
        sync_logs.deleted_products += 1
      end

      Rails.logger.info('Products synced')
    end
  end
end
