# frozen_string_literal: true

module PaymentGateway
  module FirstAtlanticCommerce
    module Client
      BASE_URL    = "https://#{Rails.env.production? ? 'gateway' : 'staging'}.ptranz.com/api/spi".freeze
      MERCHANT_ID = Rails.application.credentials[Rails.env.production? ? :fac_merchant_id : :fac_merchant_id_test]
      PASSWORD    = Rails.application.credentials[Rails.env.production? ? :fac_password : :fac_password_test]

      RepairShoprApiError      = Class.new(StandardError)
      BadRequestError          = Class.new(RepairShoprApiError)
      UnauthorizedError        = Class.new(RepairShoprApiError)
      ForbiddenError           = Class.new(RepairShoprApiError)
      NotFoundError            = Class.new(RepairShoprApiError)
      UnprocessableEntityError = Class.new(RepairShoprApiError)
      ApiError                 = Class.new(RepairShoprApiError)

      HTTP_OK_CODE                   = 200
      HTTP_BAD_REQUEST_CODE          = 400
      HTTP_UNAUTHORIZED_CODE         = 401
      HTTP_FORBIDDEN_CODE            = 403
      HTTP_NOT_FOUND_CODE            = 404
      HTTP_UNPROCESSABLE_ENTITY_CODE = 429

      def request(http_method:, endpoint:, params: {})
        @response = client.public_send(http_method, endpoint, params)

        return JSON.parse(@response.body).symbolize_keys if @response.status == HTTP_OK_CODE

        raise error_class, "Code: #{@response.status}, response: #{@response.body}"
      end

      private

      def client
        Faraday.new(BASE_URL) do |client|
          client.request :url_encoded
          client.adapter Faraday.default_adapter # The default adapter is :net_http
          client.headers = {
            'Content-Type' => 'application/json',
            'PowerTranz-PowerTranzId' => MERCHANT_ID,
            'PowerTranz-PowerTranzPassword' => PASSWORD
          }
        end
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
end
