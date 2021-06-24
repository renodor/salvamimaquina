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
      product = variant.product
      variant.destroy!
      product.destroy! unless product.has_variants?
      sync_logs.deleted_products += 1
    end

    # Destroy brands taxons that don't have any products
    # This need to be done here because brand taxons are created through RepairShopr product notes, because it is not a RS native feature
    # (On the contrary categories taxons are created through RepairShopr product categories and can be easily sync (and thus destroyed if needed) through the sync product categories feature)
    brands_taxonomy = Spree::Taxonomy.includes(taxons: :products).find_by!(name: 'Brands') # TODO: memoize that... It can even be initialized at the beginning of this class and passed along to RepairShoprApi::V1::SyncProduct
    brands_taxons = brands_taxonomy.taxons.where.not(parent_id: nil)
    brands_taxons.each { |brands_taxon| brands_taxon.destroy! if brands_taxon.products.blank? }

    Rails.logger.info('Products synced')
  end
end
