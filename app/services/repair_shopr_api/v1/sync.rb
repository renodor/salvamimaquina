# frozen_string_literal: true

class RepairShoprApi::V1::Sync < RepairShoprApi::V1::Base
  class << self
    def call(sync_logs:)
      Rails.logger.info('Start to sync RepairShopr')

      # taxon_ids = RepairShoprApi::V1::SyncProductCategories.call(sync_logs: sync_logs)
      RepairShoprApi::V1::SyncProducts.call(sync_logs: sync_logs)

      # Destroy taxons not associed to any products
      Spree::Taxon.where.not(id: Spree::Taxon.joins(:classifications).uniq.pluck(:id)).destroy_all

      Rails.logger.info('RepairShopr synced')
    end
  end
end
