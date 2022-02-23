# frozen_string_literal: true

# Runs every day at 5:00 AM UTC
task sync_repair_shopr: :environment do
  sync_logs = RepairShoprProductsSyncLog.create!
  RepairShoprApi::V1::Sync.call(sync_logs: sync_logs)
end
