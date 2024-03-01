# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SyncRepairShoprProductsJob, type: :job do
  it 'calls RepairShoprApi::V1::SyncProducts' do
    sync_logs = create(:repair_shopr_products_sync_log)
    allow(RepairShoprApi::V1::SyncProducts).to receive(:call)
    expect(RepairShoprApi::V1::SyncProducts).to receive(:call).with(sync_logs: sync_logs)

    described_class.perform_now(sync_logs)
  end
end
