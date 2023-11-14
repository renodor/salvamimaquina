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

    # Destroy taxons not associed to any products
    taxons = Spree::Taxon.where.not(parent_id: nil)
    deleted_taxons = taxons.where.not(id: Spree::Taxon.joins(:classifications).uniq.pluck(:id)).destroy_all

    sync_logs.synced_product_categories = Spree::Taxon.where.not(parent_id: nil).count
    sync_logs.deleted_product_categories = deleted_taxons.size
    sync_logs.update!(status: sync_logs.sync_errors.any? ? 'error' : 'complete')

    Rails.logger.info('Products synced')
  end
end
