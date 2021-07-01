# frozen_string_literal: true

task sync_repair_shopr: :environment do
  sync_logs = RepairShoprProductsSyncLog.new
  RepairShoprApi::V1::SyncEverything.call(sync_logs: sync_logs)
  sync_logs.save!

  Sentry.capture_message('RepairShopr Daily Sync', extra: { sync_logs_errors: sync_logs.sync_errors }) if sync_logs.sync_errors.any?
end
