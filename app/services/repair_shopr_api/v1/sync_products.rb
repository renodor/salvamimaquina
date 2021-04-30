# frozen_string_literal: true

class RepairShoprApi::V1::SyncProducts < RepairShoprApi::V1::Base
  class << self
    def call(sync_logs:)
      Rails.logger.info('Start to sync products')

      get_products.each do |product|
        RepairShoprApi::V1::SyncProduct.call(attributes: product, sync_logs: sync_logs)
      end

      Rails.logger.info('Products synced')
    end
  end
end
