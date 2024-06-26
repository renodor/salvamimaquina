# frozen_string_literal: true

class RepairShoprApi::V1::Base
  API_PATH = "https://#{Rails.application.credentials.repair_shopr_subdomain}.repairshopr.com/api/v1".freeze
  API_KEY = Rails.application.credentials.repair_shopr_api_key
  RS_ROOT_CATEGORY_NAME = 'ecom'

  RepairShoprApiError = Class.new(StandardError)
  BadRequestError = Class.new(RepairShoprApiError)
  UnauthorizedError = Class.new(RepairShoprApiError)
  ForbiddenError = Class.new(RepairShoprApiError)
  NotFoundError = Class.new(RepairShoprApiError)
  UnprocessableEntityError = Class.new(RepairShoprApiError)
  TooManyRequestsError = Class.new(RepairShoprApiError)
  ApiError = Class.new(RepairShoprApiError)

  HTTP_OK_CODE = 200
  HTTP_BAD_REQUEST_CODE = 400
  HTTP_UNAUTHORIZED_CODE = 401
  HTTP_FORBIDDEN_CODE = 403
  HTTP_NOT_FOUND_CODE = 404
  HTTP_UNPROCESSABLE_ENTITY_CODE = 422
  HTTP_TOO_MANY_REQUESTS = 429

  class << self
    # rubocop:disable Naming/AccessorMethodName
    def me
      request(http_method: :get, endpoint: 'me')
    end

    # Only retrieve enabled products, belonging to "ecom" category or sub categories
    def get_products
      # Find root category and all categories below, and get their ids
      product_categories_ids = get_product_categories(include_root_category: true).map { |category| category['id'] }
      products = []

      # Only fetch products belonging to those categories
      product_categories_ids.each do |product_category_id|
        payload = request(http_method: :get, endpoint: "products?category_id=#{product_category_id}")
        products += payload['products']

        # Fetch every pages
        # starting at page 2 because we already fetched page 1 to have the total_pages count
        # if there is only 1 page, it will iterate over range (2..1) which won't do anything
        (2..payload['meta']['total_pages']).each do |page|
          products += request(http_method: :get, endpoint: "products?category_id=#{product_category_id}&page=#{page}")['products']
        end
      end

      products.reject { |product| product['disabled'] }
    end

    def get_product(id)
      request(http_method: :get, endpoint: "products/#{id}")['product']
    end

    def get_product_categories(include_root_category: false)
      product_categories = request(http_method: :get, endpoint: 'products/categories')['categories']
      root_category = product_categories.detect { |product_category| product_category['name'] == RS_ROOT_CATEGORY_NAME }

      return [] unless root_category

      # Get only categories below the root category
      ecom_product_categories = product_categories.filter do |product_category|
        product_category['ancestry'].to_s.split('/').first == root_category['id'].to_s
      end

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
      if Rails.env.production? || http_method == :get
        @response = client.public_send(http_method, endpoint, params)
        parsed_response = Oj.load(@response.body)

        return parsed_response if @response.status == HTTP_OK_CODE

        raise error_class, "Code: #{@response.status}, response: #{parsed_response}"
      else
        FakeApiCall.new(
          current_base_url: 'http://localhost:3000',
          http_method: http_method,
          endpoint: endpoint,
          payload: params,
          response: fake_response(endpoint, params)
        ).call
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
      when HTTP_TOO_MANY_REQUESTS
        TooManyRequestsError
      else
        ApiError
      end
    end

    # rubocop:disable Metrics/MethodLength
    def fake_response(endpoint, payload)
      case endpoint
      when /invoices/
        {
          'invoice' => {
            'id' => 1,
            'customer_id' => payload[:customer_id],
            'customer_business_then_name' => 'Walkin Customer',
            'number' => payload[:number],
            'created_at' => DateTime.current,
            'updated_at' => DateTime.current,
            'date' => payload[:date],
            'due_date' => payload[:date],
            'subtotal' => payload[:subtotal],
            'total' => payload[:total],
            'tax' => payload[:tax],
            'verified_paid' => false,
            'tech_marked_paid' => false,
            'ticket_id' => nil,
            'pdf_url' => nil,
            'is_paid' => true,
            'location_id' => payload[:location_id],
            'po_number' => nil,
            'contact_id' => nil,
            'note' => payload[:note],
            'hardwarecost' => nil,
            'user_id' => 1
          }
        }
      when /customers/
        {
          'customer' => {
            'id' => 1,
            'firstname' => payload[:firstname],
            'lastname' => payload[:lastname],
            'fullname' => payload[:fullname],
            'business_name' => nil,
            'email' => payload[:email],
            'phone' => payload[:phone],
            'mobile' => nil,
            'created_at' => DateTime.current,
            'updated_at' => DateTime.current,
            'pdf_url' => nil,
            'address' => payload[:address],
            'address_2' => payload[:address_2],
            'city' => payload[:city],
            'state' => payload[:state],
            'zip' => nil,
            'latitude' => nil,
            'longitude' => nil,
            'notes' => payload[:notes],
            'get_sms' => false,
            'opt_out' => false,
            'disabled' => false,
            'no_email' => true,
            'location_name' => nil,
            'location_id' => nil,
            'properties' => {},
            'online_profile_url' => nil,
            'tax_rate_id' => nil,
            'notification_email' => nil,
            'invoice_cc_emails' => nil,
            'invoice_term_id' => nil,
            'referred_by' => nil,
            'ref_customer_id' => nil,
            'business_and_full_name' => payload[:fullname],
            'business_then_name' => payload[:fullname],
            'contacts' => []
          }
        }
      end
    end
    # rubocop:enable Metrics/MethodLength
  end
end
