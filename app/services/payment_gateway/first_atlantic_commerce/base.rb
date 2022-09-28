# frozen_string_literal: true

module PaymentGateway
  class FirstAtlanticCommerce::Base
    BASE_URL = "https://#{Rails.env.production? ? 'TBD' : 'staging'}.ptranz.com/api/spi"
    # ACQUIRER_ID = Rails.application.credentials.fac_acquirer_id
    MERCHANT_ID = Rails.application.credentials[:fac_merchant_id]
    PASSWORD = Rails.application.credentials[:fac_password]
    PURCHASE_CURRENCY = 840 # FAC code for USD

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
      private

      def authorize(json_payload)
        request(http_method: :post, endpoint: 'sale', params: json_payload)
      end

      # def authorize_3ds(xml_payload)
      #   request(http_method: :post, endpoint: '3DS2/Authenticate', params: xml_payload)
      # end

      def payment(spi_token)
        request(http_method: :post, endpoint: 'payment', params: spi_token)
      end

      def tokenize(xml_payload)
        request(http_method: :post, endpoint: 'Tokenize', params: xml_payload)
      end

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

      def request(http_method:, endpoint:, params: {})
        @response = client.public_send(http_method, endpoint, params)

        return JSON.parse(@response.body).symbolize_keys if @response.status == HTTP_OK_CODE

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
end
