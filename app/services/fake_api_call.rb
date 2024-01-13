# frozen_string_literal:true

class FakeApiCall
  attr_reader :current_base_url, :http_method, :endpoint, :payload, :response

  def initialize(current_base_url:, http_method:, endpoint:, payload:, response:)
    @current_base_url = current_base_url
    @http_method = http_method
    @endpoint = endpoint
    @payload = payload
    @response = response
  end

  def call
    params = URI.encode_www_form({ http_method: http_method, endpoint: endpoint, payload: payload.to_json, response: response.to_json })
    Launchy.open("#{current_base_url}/fake_api_call/show_request?#{params}")
    response
  end
end