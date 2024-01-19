# frozen_string_literal: true

class SyncRepairShoprProductsJob < ApplicationJob
  queue_as :default

  def perform(sync_logs)
    RepairShoprApi::V1::SyncProducts.call(sync_logs: sync_logs)
  end
end
