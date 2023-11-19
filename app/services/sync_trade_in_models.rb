# frozen_string_literal: true

require 'csv'

class SyncTradeInModels
  FILE_ID = Rails.application.credentials.trade_in_google_sheet_id

  SyncTradeInModelsError = Class.new(StandardError)

  class << self
    def call
      response = request(http_method: :get, endpoint: "d/#{FILE_ID}/gviz/tq", params: { tqx: 'out:csv' })

      TradeInCategory.destroy_all

      CSV.parse(response, headers: :first_row).each_with_index do |row, line_number|
        trade_in_category = TradeInCategory.find_or_create_by!(name: row[0])
        trade_in_category.trade_in_models.create!(
          name: row[1],
          min_value: row[2].delete('$').to_f,
          max_value: row[3].delete('$').to_f,
          order: line_number
        )
      end

      { success?: true }
    rescue ActiveRecord::RecordInvalid, SyncTradeInModelsError => e
      Sentry.capture_exception(e)
      { success?: false }
    end

    private

    def client
      Faraday.new('https://docs.google.com/spreadsheets') do |client|
        client.request :url_encoded
        client.adapter Faraday.default_adapter # The default adapter is :net_http
      end
    end

    def request(http_method:, endpoint:, params: {})
      response = client.public_send(http_method, endpoint, params)

      return response.body if response.status == 200

      raise SyncTradeInModelsError, "Code: #{response.status}, response: #{response.body}"
    end
  end
end
