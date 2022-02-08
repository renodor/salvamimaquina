# frozen_string_literal: true

require 'csv'

class ImportTradeInFromGoogleSheet
  FILE_ID = '194r_WUSKRb1M_PVi_5kpkWimX-BmJ5GhmAWthFW-wBU'

  class << self
    def call
      response = request(http_method: :get, endpoint: "d/#{FILE_ID}/gviz/tq", params: { tqx: 'out:csv' })

      TradeInCategory.destroy_all

      CSV.parse(response, headers: :first_row).each do |row|
        trade_in_category = TradeInCategory.create!(name: row[0])
        trade_in_category.trade_in_models.create!(name: row[1], min_value: row[2].delete('$').to_f, max_value: row[3].delete('$').to_f)
      end

      # TODO: return open struct with display flash success etc...
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

      # TODO: return open struct with success false, send event to sentry, display flash error message
      raise "Code: #{response.status}, response: #{response.body}"
    end
  end
end
