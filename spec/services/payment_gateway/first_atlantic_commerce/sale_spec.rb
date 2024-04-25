# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaymentGateway::FirstAtlanticCommerce::Sale, type: :service do
  subject { described_class.new(order_info: order_info, card_info: card_info).call }

  describe 'call' do
    let(:order_info) do
      {
        transaction_uuid: 'fake_uuid',
        amount: 12.34,
        number: '123ABCD',
        email: 'cool_client@gmail.com',
        billing_address: {
          name: 'Cool Client',
          address1: '2 Cool street',
          address2: 'Next to another street',
          city: 'Cool City'
        }
      }
    end
    let(:card_info) do
      {
        number: '12345678',
        cvv: '333',
        expiry_date: '0419',
        name: 'Cool Client'
      }
    end
    let(:expected_payload) do
      {
        TransactionIdentifier: 'fake_uuid',
        TotalAmount: 12.34,
        CurrencyCode: 840,
        ThreeDSecure: true,
        Source: {
          CardPan: '12345678',
          CardCvv: '333',
          CardExpiration: '0419',
          CardholderName: 'Cool Client'
        },
        OrderIdentifier: '123ABCD',
        BillingAddress: {
          FirstName: 'Cool',
          LastName: 'Client',
          Line1: '2 Cool street',
          Line2: 'Next to another street',
          City: 'Cool City',
          County: 'Panamá',
          CountryCode: 591,
          EmailAddress: 'cool_client@gmail.com'
        },
        ExtendedData: {
          ThreeDSecure: {
            ChallengeWindowSize: 5,
            MerchantResponseUrl: '01'
          },
          MerchantResponseUrl: 'https://12ef-2a02-842a-f751-4c01-fe98-f57f-8039-1532.ngrok-free.app/checkout/three_d_secure_response'
        }
      }.to_json
    end

    it 'calls sale endpoint with the correct payload and return cleaned response' do
      stub_request(:post, 'https://staging.ptranz.com/api/spi/sale')
        .with(body: expected_payload)
        .to_return(
          status: 200,
          body: {
            IsoResponseCode: 'SP4',
            ResponseMessage: 'Cool response',
            RedirectData: '<html><body>Cool</body></html>'
          }.to_json
        )

      expect(subject)
        .to eq(
          {
            success: true,
            iso_response_code: 'SP4',
            message: 'Cool response',
            html_form: '<html><body>Cool</body></html>'
          }
        )
    end

    it 'doesnt resturn success response when response code is not SP4' do
      stub_request(:post, 'https://staging.ptranz.com/api/spi/sale')
        .to_return(
          status: 200,
          body: {
            IsoResponseCode: '00',
            ResponseMessage: 'Not cool response',
            RedirectData: '<html><body>Not cool</body></html>'
          }.to_json
        )

      expect(subject)
        .to eq(
          {
            success: false,
            iso_response_code: '00',
            message: 'Not cool response',
            html_form: '<html><body>Not cool</body></html>'
          }
        )
    end
  end
end
