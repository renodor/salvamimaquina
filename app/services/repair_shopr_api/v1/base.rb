# frozen_string_literal: true

class RepairShoprApi::V1::Base
  API_PATH = "https://#{Rails.application.credentials.repair_shopr_subdomain}.repairshopr.com/api/v1"
  API_KEY = Rails.application.credentials.repair_shopr_api_key
  RS_ROOT_CATEGORY_NAME = 'ecom'

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
    def me
      request(http_method: :get, endpoint: 'me')
    end

    # Only retrieve enabled products, belonging to "ecom" category or sub categories
    def get_products
      # Find root category and all categories below, and get their ids
      product_categorie_ids = get_product_categories(include_root_category: true).map { |category| category['id'] }
      products = []

      # Only fetch products belonging to those categories
      product_categorie_ids.each do |product_category_id|
        payload = request(http_method: :get, endpoint: "products?category_id=#{product_category_id}")

        # Fetch every pages
        # For the first iteration (n == 0), we already have the payload, we got it in order to have the total pages
        # For other iterations, we need to fetch the payload again at the correct page (starting at page 2)
        # And each time we need to exclude disabled products
        payload['meta']['total_pages'].times do |n|
          payload = request(http_method: :get, endpoint: "products?category_id=#{product_category_id}&page=#{n + 1}") if n.positive?
          products += payload['products'].reject { |product| product['disabled'] }
        end
      end

      products
    end

    def get_product(id)
      request(http_method: :get, endpoint: "products/#{id}")['product']
    end

    def get_product_categories(include_root_category: false)
      product_categories = request(http_method: :get, endpoint: 'products/categories')['categories']
      root_category = product_categories.detect { |product_category| product_category['name'] == RS_ROOT_CATEGORY_NAME }

      return [] unless root_category

      # Get only categories below the root category
      ecom_product_categories = product_categories.filter { |product_category| product_category['ancestry']&.include?(root_category['id'].to_s) }

      # Return filtered categories including or not root category depending on given argument
      include_root_category ? ecom_product_categories + [root_category] : ecom_product_categories
    end

    def get_customer_by_email(email)
      request(http_method: :get, endpoint: "customers?include_disabled=true&email=#{email}")['customers'].first
    end

    def create_customer(customer_info)
      request(http_method: :post, endpoint: 'customers', params: customer_info)['customer']
    end

    def update_customer(id, customer_info)
      request(http_method: :put, endpoint: "customers/#{id}", params: customer_info)
    end

    def post_invoices(invoice)
      request(http_method: :post, endpoint: 'invoices', params: invoice)
    end

    def post_line_items(invoice_id, line_item)
      request(http_method: :post, endpoint: "invoices/#{invoice_id}/line_items", params: line_item)
    end

    def post_payments(payment)
      request(http_method: :post, endpoint: 'payments', params: payment)
    end

    def get_business_hours
      request(http_method: :get, endpoint: 'settings')['business_hours']
    end
    # rubocop:enable Naming/AccessorMethodName

    private

    def client
      Faraday.new(API_PATH) do |client|
        client.request :url_encoded
        client.adapter Faraday.default_adapter # The default adapter is :net_http
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
