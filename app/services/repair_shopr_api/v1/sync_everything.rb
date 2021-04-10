# frozen_string_literal: true

class RepairShoprApi::V1::SyncEverything < RepairShoprApi::V1::Base
  class << self
    def call(sync_logs:)
      Rails.logger.info('Start to sync products')

      taxon_ids = RepairShoprApi::V1::SyncProductCategories.call(sync_logs: sync_logs)
      if taxon_ids
        get_products.each do |product|
          synced_product = RepairShoprApi::V1::SyncProduct.call(attributes: product, sync_logs: sync_logs)
          RepairShoprApi::V1::SyncProductImages.call(attributes: product, sync_logs: sync_logs) if synced_product
        end
      end
      Rails.logger.info('Products synced')
    end
  end
end
