# frozen_string_literal: true

class RepairShoprApi::V1::SyncProducts < RepairShoprApi::V1::Base
  class << self
    def call
      sync_logs = RepairShoprProductsSyncLog.new

      products = get_products['products']

      Rails.logger.info('Start to sync products')

      RepairShoprApi::V1::SyncProductCategories.call(sync_logs: sync_logs)

      products.each { |product| RepairShoprApi::V1::SyncProduct.call(attributes: product, sync_logs: sync_logs) }
      Rails.logger.info('Products synced')
      binding.pry
      sync_logs.save!
      sync_logs
    end
  end
end
