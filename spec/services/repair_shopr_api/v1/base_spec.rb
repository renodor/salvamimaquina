# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RepairShoprApi::V1::Base, type: :service do
  let(:api_path) { described_class::API_PATH }

  context 'in Production environment' do
    before { allow(Rails.env).to receive(:production?).and_return(true) }

    it 'makes request to the correct api path' do
      stub = stub_request(:get, "https://#{Rails.application.credentials.repair_shopr_subdomain}.repairshopr.com/api/v1/me")
      described_class.me
      expect(stub).to have_been_requested
    end

    it 'makes request with correct authorization header' do
      stub = stub_request(:get, "#{api_path}/me").with(headers: { 'Authorization' => "Bearer #{described_class::API_KEY}" })
      described_class.me
      expect(stub).to have_been_requested
    end

    describe '#me' do
      let(:user_profile) { { user_id: '1234', user_email: 'cool@email.com' } }

      it 'gets user profile' do
        stub_request(:get, "#{api_path}/me").to_return_json(body: user_profile)
        expect(described_class.me).to eq(user_profile.stringify_keys)
      end
    end

    describe '#get_products' do
      let(:fake_product) { { 'id' => 1, 'name' => 'Cool product 1' } }
      let(:fake_product2) { { 'id' => 2, 'name' => 'Cool product 2' } }
      let(:fake_product3) { { 'id' => 3, 'name' => 'Cool product 3' } }
      let(:fake_product4) { { 'id' => 4, 'name' => 'Cool product 4' } }
      let(:fake_product5) { { 'id' => 5, 'name' => 'Cool product 5' } }
      let(:fake_product6) { { 'id' => 6, 'name' => 'Cool product 6' } }
      let(:fake_product7) { { 'id' => 7, 'name' => 'Cool product 7' } }

      it 'gets all products belonging to repair shopr ecom root category and sub categories' do
        stub_request(:get, "#{api_path}/products/categories").to_return_json(
          body: {
            categories: [
              {
                id: 1,
                ancestry: nil,
                name: 'ecom'
              },
              {
                id: 2,
                ancestry: '1',
                name: 'Phones'
              },
              {
                id: 3,
                ancestry: '1/2',
                name: 'iPhones'
              }
            ]
          }
        )

        stub_request(:get, "#{api_path}/products").with(query: { category_id: 1 }).to_return_json(
          body: {
            products: [fake_product],
            meta: { total_pages: 1 }
          }
        )

        stub_request(:get, "#{api_path}/products").with(query: { category_id: 2 }).to_return_json(
          body: {
            products: [fake_product2, fake_product3],
            meta: { total_pages: 3 }
          }
        )

        stub_request(:get, "#{api_path}/products").with(query: { category_id: 2, page: 2 }).to_return_json(
          body: {
            products: [fake_product4, fake_product5],
            meta: { total_pages: 3 }
          }
        )

        stub_request(:get, "#{api_path}/products").with(query: { category_id: 2, page: 3 }).to_return_json(
          body: {
            products: [fake_product6],
            meta: { total_pages: 3 }
          }
        )

        stub_request(:get, "#{api_path}/products").with(query: { category_id: 3 }).to_return_json(
          body: {
            products: [fake_product7],
            meta: { total_pages: 1 }
          }
        )

        expect(described_class.get_products).to contain_exactly(fake_product, fake_product2, fake_product3, fake_product4, fake_product5, fake_product6, fake_product7)
      end
    end

    describe '#get_product' do
      let(:fake_product) { { 'id' => 1, 'name' => 'Cool product 1' } }

      it 'get product' do
        stub_request(:get, "#{api_path}/products/#{fake_product['id']}").to_return_json(body: { product: fake_product })

        expect(described_class.get_product(fake_product['id'])).to eq(fake_product)
      end
    end

    describe '#get_product_categories' do
      let(:ecom_root_category) { { 'id' => 1, 'ancestry' => nil, 'name' => 'ecom' } }
      let(:product_category) { { 'id' => 2, 'ancestry' => '1', 'name' => 'Phones' } }
      let(:product_category2) { { 'id' => 3, 'ancestry' => '1/2', 'name' => 'iPhones' } }
      let(:product_category3) { { 'id' => 3, 'ancestry' => nil, 'name' => 'Other' } }
      let(:product_category4) { { 'id' => 4, 'ancestry' => '3', 'name' => 'Laptops' } }

      before do
        stub_request(:get, "#{api_path}/products/categories").to_return_json(
          body: {
            categories: [ecom_root_category, product_category, product_category2, product_category3, product_category4]
          }
        )
      end

      context 'when include_root_category is true' do
        it 'gets all product categories below the ecom root category, including the ecom root category' do
          expect(described_class.get_product_categories(include_root_category: true)).to contain_exactly(ecom_root_category, product_category, product_category2)
        end
      end

      context 'when include_root_category is true' do
        it 'gets all product categories below the ecom root category, without the ecom root category' do
          expect(described_class.get_product_categories(include_root_category: false)).to contain_exactly(product_category, product_category2)
        end
      end
    end

    describe '#get_customer_by_email' do
      let(:email) { 'cool@email.com' }
      let(:fake_customer) { { 'id' => 1, 'name' => 'Cool customer 1', 'email' => email } }

      it 'get customer with the given email' do
        stub_request(:get, "#{api_path}/customers?include_disabled=true&email=#{email}").to_return_json(body: { customers: [fake_customer] })

        expect(described_class.get_customer_by_email(email)).to eq(fake_customer)
      end
    end

    describe '#create_customer' do
      let(:fake_customer_payload) { { 'name' => 'Cool customer 1' } }
      let(:fake_customer) { fake_customer_payload.merge({ 'id' => 1 }) }

      it 'send post request to create customer' do
        stub_request(:post, "#{api_path}/customers").with(body: fake_customer_payload).to_return_json(body: { customer: fake_customer })

        expect(described_class.create_customer(fake_customer_payload)).to eq(fake_customer)
      end
    end

    describe '#update_customer' do
      let(:fake_customer) { { 'id' => 1, 'name' => 'Cooler customer 1' } }

      it 'send put request to update customer' do
        stub_request(:put, "#{api_path}/customers/#{fake_customer['id']}").with(body: fake_customer)

        described_class.update_customer(fake_customer['id'], fake_customer)
      end
    end

    describe '#post_invoces' do
      let(:fake_invoice) { { 'total' => 100 } }

      it 'send post request to create invoice' do
        stub_request(:post, "#{api_path}/invoices").with(body: fake_invoice)

        described_class.post_invoices(fake_invoice)
      end
    end

    describe '#post_line_items' do
      let(:fake_invoice_id) { 1 }
      let(:fake_invoice_line_item) { { 'invoice_id' => fake_invoice_id, 'item' => 'iPhone' } }

      it 'send post request to create invoice line item' do
        stub_request(:post, "#{api_path}/invoices/#{fake_invoice_id}/line_items").with(body: fake_invoice_line_item)

        described_class.post_line_items(fake_invoice_id, fake_invoice_line_item)
      end
    end

    describe '#post_payments' do
      let(:fake_payment) { { 'amount_cents' => 1000 } }

      it 'send post request to create invoice' do
        stub_request(:post, "#{api_path}/payments").with(body: fake_payment)

        described_class.post_payments(fake_payment)
      end
    end

    describe '#get_business_hours' do
      let(:fake_business_hours) { ['day' => 'Monday', 'start' => '9:00'] }

      it 'get business hours' do
        stub_request(:get, "#{api_path}/settings").to_return_json(body: { business_hours: fake_business_hours })

        expect(described_class.get_business_hours).to eq(fake_business_hours)
      end
    end

    context 'error management' do
      it 'raises bas request error' do
        error = { 'error' => 'bad request' }
        stub_request(:get, "#{api_path}/me").to_return_json(body: error, status: 400)
        expect { described_class.me }.to raise_error(described_class::BadRequestError, "Code: 400, response: #{error}")
      end

      it 'raises unauthorized error' do
        error = { 'error' => 'unauthorized' }
        stub_request(:get, "#{api_path}/me").to_return_json(body: error, status: 401)
        expect { described_class.me }.to raise_error(described_class::UnauthorizedError, "Code: 401, response: #{error}")
      end

      it 'raises forbidden error' do
        error = { 'error' => 'forbidden' }
        stub_request(:get, "#{api_path}/me").to_return_json(body: error, status: 403)
        expect { described_class.me }.to raise_error(described_class::ForbiddenError, "Code: 403, response: #{error}")
      end

      it 'raises not found error' do
        error = { 'error' => 'not found' }
        stub_request(:get, "#{api_path}/me").to_return_json(body: error, status: 404)
        expect { described_class.me }.to raise_error(described_class::NotFoundError, "Code: 404, response: #{error}")
      end

      it 'raises unprocessable entity error' do
        error = { 'error' => 'unprocessable entity' }
        stub_request(:get, "#{api_path}/me").to_return_json(body: error, status: 422)
        expect { described_class.me }.to raise_error(described_class::UnprocessableEntityError, "Code: 422, response: #{error}")
      end

      it 'raises too many requests error' do
        error = { 'error' => 'too many requests' }
        stub_request(:get, "#{api_path}/me").to_return_json(body: error, status: 429)
        expect { described_class.me }.to raise_error(described_class::TooManyRequestsError, "Code: 429, response: #{error}")
      end

      it 'raises generic api error' do
        error = { 'error' => 'api error' }
        stub_request(:get, "#{api_path}/me").to_return_json(body: error, status: 500)
        expect { described_class.me }.to raise_error(described_class::ApiError, "Code: 500, response: #{error}")
      end
    end
  end

  context 'in non-production environments' do
    context 'for get requests' do
      it 'sends get requests' do
        stub = stub_request(:get, "#{api_path}/me")
        described_class.me
        expect(stub).to have_been_requested
      end
    end

    context 'for other requests' do
      let(:fake_api_call_instance_double) { instance_double(FakeApiCall) }

      before do
        allow(FakeApiCall).to receive(:new).and_return(fake_api_call_instance_double)
        allow(fake_api_call_instance_double).to receive(:call)
      end

      it 'doesnt send post requests, and calls FakeApiCall instead' do
        stub_post = stub_request(:post, "#{api_path}/invoices")
        fake_invoice = { 'total' => 100 }

        expect(FakeApiCall).to receive(:new).with(
          {
            current_base_url: 'http://localhost:3000',
            http_method: :post,
            endpoint: 'invoices',
            payload: fake_invoice,
            response: include('invoice')
          }
        )
        expect(fake_api_call_instance_double).to receive(:call)
        described_class.post_invoices(fake_invoice)
        expect(stub_post).not_to have_been_requested
      end

      it 'doesnt send put requests, and calls FakeApiCall instead' do
        fake_customer = { 'id' => 1, 'name' => 'Cooler customer 1' }
        stub_post = stub_request(:put, "#{api_path}/customers/#{fake_customer['id']}")

        expect(FakeApiCall).to receive(:new).with(
          {
            current_base_url: 'http://localhost:3000',
            http_method: :put,
            endpoint: "customers/#{fake_customer['id']}",
            payload: fake_customer,
            response: include('customer')
          }
        )
        expect(fake_api_call_instance_double).to receive(:call)
        described_class.update_customer(fake_customer['id'], fake_customer)
        expect(stub_post).not_to have_been_requested
      end
    end
  end
end
