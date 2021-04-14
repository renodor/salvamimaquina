# frozen_string_literal: true

class RepairShoprApi::V1::SyncEverything < RepairShoprApi::V1::Base
  class << self
    def call(sync_logs:)
      Rails.logger.info('Start to sync products')

      taxon_ids = RepairShoprApi::V1::SyncProductCategories.call(sync_logs: sync_logs)
      RepairShoprApi::V1::SyncProducts.call(sync_logs: sync_logs) if taxon_ids

      Rails.logger.info('Products synced')
    end
  end
end
