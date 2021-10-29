# frozen_string_literal: true

class SyncRepairShoprJob < ApplicationJob
  queue_as :default

  def perform(sync_logs)
    RepairShoprApi::V1::Sync.call(sync_logs: sync_logs)
  end
end
