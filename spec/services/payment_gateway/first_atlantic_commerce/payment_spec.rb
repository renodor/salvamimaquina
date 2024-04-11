# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaymentGateway::FirstAtlanticCommerce::Payment, type: :service do
  describe 'call' do
    it 'calls payment endpoint and returns cleaned response' do
      stub_request(:post, 'https://staging.ptranz.com/api/spi/payment')
        .with(body: '12345'.to_json)
        .to_return(
          status: 200,
          body: {
            Approved: true,
            ResponseMessage: 'Cool payment',
            IsoResponseCode: 'SP4'
          }.to_json
        )

      expect(described_class.new(spi_token: '12345').call)
        .to eq(
          {
            success: true,
            message: 'Cool payment',
            iso_response_code: 'SP4'
          }
        )
    end
  end
end
