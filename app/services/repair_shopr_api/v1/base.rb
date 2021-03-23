# frozen_string_literal: true

class RepairShoprApi::V1::Base
  API_ENDPOINT = 'https://coolshop.repairshopr.com/api/v1'
  API_KEY = Rails.application.credentials.repair_shopr_api_key_test

  RepairShoprApiError = Class.new(StandardError)
  BadRequestError = Class.new(RepairShoprApiError)
  UnauthorizedError = Class.new(RepairShoprApiError)
  ForbiddenError = Class.new(RepairShoprApiError)
  NotFoundError = Class.new(RepairShoprApiError)
  UnprocessableEntityError = Class.new(RepairShoprApiError)
  ApiError = Class.new(RepairShoprApiError)

  HTTP_OK_CODE = 200
  HTTP_BAD_REQUEST_CODE = 400
  HTTP_UNAUTHORIZED_CODE = 401
  HTTP_FORBIDDEN_CODE = 403
  HTTP_NOT_FOUND_CODE = 404
  HTTP_UNPROCESSABLE_ENTITY_CODE = 429

  class << self
    # rubocop:disable Naming/AccessorMethodName
    def get_product(id)
      request(http_method: :get, endpoint: "products/#{id}")
    end

    def get_product_categories
      request(http_method: :get, endpoint: 'products/categories')
    end
    # rubocop:enable Naming/AccessorMethodName

    private

    def client
      Faraday.new(API_ENDPOINT) do |client|
        client.request :url_encoded
        client.adapter Faraday.default_adapter # :net_http
        client.headers['Authorization'] = "Bearer #{API_KEY}"
      end
    end

    def request(http_method:, endpoint:, params: {})
      @response = client.public_send(http_method, endpoint, params)
      parsed_response = Oj.load(@response.body)

      return parsed_response if @response.status == HTTP_OK_CODE

      raise error_class, "Code: #{@response.status}, response: #{@response.body}"
    end

    def error_class
      case @response.status
      when HTTP_BAD_REQUEST_CODE
        BadRequestError
      when HTTP_UNAUTHORIZED_CODE
        UnauthorizedError
      when HTTP_FORBIDDEN_CODE
        ForbiddenError
      when HTTP_NOT_FOUND_CODE
        NotFoundError
      when HTTP_UNPROCESSABLE_ENTITY_CODE
        UnprocessableEntityError
      else
        ApiError
      end
    end
  end
end
