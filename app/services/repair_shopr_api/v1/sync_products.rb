# frozen_string_literal: true

class RepairShoprApi::V1::SyncProducts < RepairShoprApi::V1::Base
  class << self
    def call
      sync_logs = RepairShoprProductsSyncLog.new

      products = get_products['products']
      Rails.logger.info('Start to sync products')

      taxon_ids = RepairShoprApi::V1::SyncProductCategories.call(sync_logs: sync_logs)
      if taxon_ids
        products.each do |product|
          synced_product = RepairShoprApi::V1::SyncProduct.call(attributes: product, sync_logs: sync_logs)
          RepairShoprApi::V1::SyncProductImages.call(attributes: product, sync_logs: sync_logs) if synced_product
        end
      end
      Rails.logger.info('Products synced')
      sync_logs.save!

      Sentry.capture_message(name, extra: {sync_logs_errors: sync_logs.sync_errors }) if sync_logs.sync_errors.any?
      sync_logs
    end
  end
end
