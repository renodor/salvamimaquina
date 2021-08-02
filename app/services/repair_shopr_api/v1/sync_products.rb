# frozen_string_literal: true

class RepairShoprApi::V1::SyncProducts < RepairShoprApi::V1::Base
  def self.call(sync_logs:)
    Rails.logger.info('Start to sync products')

    products = get_products
    # Sync all products
    products.each do |product|
      RepairShoprApi::V1::SyncProduct.call(attributes: product, sync_logs: sync_logs)
    end

    # Destroy products that are on Solidus but where not fetched on RepairShopr
    # (They were probably disabled on RepairShoper, or removed from the ecom category)
    # Also products with variants can have a master without repair_shopr_id. But other than that repair_shopr_id can't be nil
    variants_to_destroy = Spree::Variant.where.not(repair_shopr_id: products.map { |product| product['id'] })
                                        .or(Spree::Variant.where(repair_shopr_id: nil, is_master: false))
    variants_to_destroy.each do |variant|
      variant.destroy_and_destroy_product_if_no_other_variants!
      sync_logs.deleted_products += 1
    end

    Rails.logger.info('Products synced')
  end
end
