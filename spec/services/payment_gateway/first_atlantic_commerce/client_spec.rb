# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaymentGateway::FirstAtlanticCommerce::Client, type: :service do
  describe 'request' do
    subject { PaymentGateway::FirstAtlanticCommerce::Payment.new(spi_token: '12345').call }

    it 'sends request to the correct endpoint, with correct payload and headers' do
      stub_request(:post, 'https://staging.ptranz.com/api/spi/payment')
        .with(
          body: '12345'.to_json,
          headers: {
            'Content-Type' => 'application/json',
            'PowerTranz-PowerTranzId' => described_class::MERCHANT_ID,
            'PowerTranz-PowerTranzPassword' => described_class::PASSWORD
          }
        )
        .to_return(status: 200, body: {}.to_json)

      subject
    end

    it 'returns parsed response when request is successful' do
      stub_request(:post, 'https://staging.ptranz.com/api/spi/payment')
        .to_return(status: 200, body: { ResponseMessage: 'Cool message' }.to_json)

      expect(subject).to include(message: 'Cool message')
    end

    it 'rases error when request is not successful' do
      stub_request(:post, 'https://staging.ptranz.com/api/spi/payment')
        .to_return(status: 400, body: 'Not cool'.to_json)

      expect { subject }.to raise_error(described_class::BadRequestError, 'Code: 400, response: "Not cool"')
    end
  end
end
