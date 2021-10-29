# frozen_string_literal: true

class RepairShoprApi::V1::Sync < RepairShoprApi::V1::Base
  class << self
    def call(sync_logs:)
      Rails.logger.info('Start to sync RepairShopr')

      taxon_ids = RepairShoprApi::V1::SyncProductCategories.call(sync_logs: sync_logs)
      RepairShoprApi::V1::SyncProducts.call(sync_logs: sync_logs) if taxon_ids

      sync_logs.sync_errors << { fake_error: 'to test' }
      sync_logs.status = sync_logs.sync_errors.any? ? 'error' : 'complete'
      sync_logs.save!
      Sentry.capture_message(name, { extra: { sync_logs_errors: sync_logs.sync_errors } }) if sync_logs.sync_errors.any?

      Rails.logger.info('RepairShopr synced')
    end
  end
end
