# frozen_string_literal: true

module PaymentGateway
  class FirstAtlanticCommerce::Base
    BASE_URL = "https://#{Rails.env.production? ? 'marlin' : 'ecm'}.firstatlanticcommerce.com/PGServiceXML"
    ACQUIRER_ID = Rails.application.credentials.fac_acquirer_id
    MERCHANT_ID = Rails.application.credentials[Rails.env.production? ? :fac_merchant_id : :fac_merchant_id_test]
    PASSWORD = Rails.application.credentials[Rails.env.production? ? :fac_password : :fac_password_test]
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

      def authorize_3ds(xml_payload)
        request(http_method: :post, endpoint: 'Authorize3DS', params: xml_payload)
      end

      def capture(xml_payload)
        request(http_method: :post, endpoint: 'TransactionModification', params: xml_payload)
      end

      def tokenize(xml_payload)
        request(http_method: :post, endpoint: 'Tokenize', params: xml_payload)
      end

      def client
        Faraday.new(BASE_URL) do |client|
          client.request :url_encoded
          client.adapter Faraday.default_adapter # The default adapter is :net_http
          client.headers['Content-Type'] = 'text/xml'
        end
      end

      def request(http_method:, endpoint:, params: {})
        @response = client.public_send(http_method, endpoint, params)

        return @response.body if @response.status == HTTP_OK_CODE

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
