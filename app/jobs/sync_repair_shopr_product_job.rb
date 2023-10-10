# frozen_string_literal: true

class SyncRepairShoprProductJob < ApplicationJob
  queue_as :default

  def perform(sync_logs_id, attributes)
    RepairShoprApi::V1::SyncProduct.call(sync_logs_id: sync_logs_id, attributes: attributes)
  end
end
