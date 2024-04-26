# frozen_string_literal: true

# Runs every day at 5:00 AM UTC
task sync_repair_shopr: :environment do
  RepairShoprApi::V1::SyncProducts.call(sync_logs: RepairShoprProductsSyncLog.create!)
end
