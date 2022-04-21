# frozen_string_literal: true

# Runs every day at 5:00 AM UTC
task sync_trade_in_models: :environment do
  SyncTradeInModels.call
end
