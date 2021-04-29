# frozen_string_literal: true

class RepairShoprApi::V1::SyncProducts < RepairShoprApi::V1::Base
  class << self
    def call(sync_logs:)
      Rails.logger.info('Start to sync products')

      payload = get_products
      total_pages = payload['meta']['total_pages']

      total_pages.times do |n|
        products = n.zero? ? payload['products'] : get_products(n + 1)['products']
        products.each do |product|
          RepairShoprApi::V1::SyncProduct.call(attributes: product, sync_logs: sync_logs)
        end
      end
      Rails.logger.info('Products synced')
    end
  end
end
