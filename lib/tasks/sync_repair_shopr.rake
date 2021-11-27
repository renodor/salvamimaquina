# frozen_string_literal: true

task sync_repair_shopr: :environment do
  sync_logs = RepairShoprProductsSyncLog.create!
  RepairShoprApi::V1::Sync.call(sync_logs: sync_logs)
end
