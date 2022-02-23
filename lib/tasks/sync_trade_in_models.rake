# frozen_string_literal: true

task sync_trade_in_models: :environment do
  ImportTradeInFromGoogleSheet.call
end
