# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::PaymentMethod::BacCreditCard, type: :model do
  describe '#gateway_class' do
    it 'returns class' do
      expect(described_class.new.gateway_class).to eq(described_class)
    end
  end

  describe '#sale' do
    let(:card_info) do
      {
        number: '123 456 78',
        expiry: '19 / 04',
        verification_value: '333',
        name: 'Cool Clientíño'
      }
    end
    let(:order_info) do
      {
        order_id: '123ABCD',
        originator: SecureRandom,
        email: 'cool_client@gmail.com',
        billing_address: {
          name: 'Cool Clientíño',
          address1: '2 Calle De la niña con árbol de café',
          address2: 'Al lado del camino público de la tía jamón',
          city: 'Cool City'
        }
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
          CardholderName: 'Cool Clientino'
        },
        OrderIdentifier: '123ABCD',
        BillingAddress: {
          FirstName: 'Cool',
          LastName: 'Clientino',
          Line1: '2 Calle De la nina con arbol de cafe',
          Line2: 'Al lado del camino publico de la tia jamon',
          City: 'Cool City',
          County: 'Panama',
          CountryCode: 591,
          EmailAddress: 'cool_client@gmail.com'
        },
        ExtendedData: {
          ThreeDSecure: {
            ChallengeWindowSize: 5,
            MerchantResponseUrl: '01'
          },
          MerchantResponseUrl: /https:\/\/.+\/checkout\/three_d_secure_response/
        }
      }
    end

    it 'calls FAC sale endpoint with the correct payload replacing special characters and return an active merchant response' do
      allow(SecureRandom).to receive(:uuid).and_return('fake_uuid')

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

      response = described_class.new.sale(1234, card_info, order_info)
      expect(response).to be_a(ActiveMerchant::Billing::Response)
      expect(response.success?).to be true
      expect(response.message).to eq('Cool response')
      expect(response.params).to eq(
        {
          'html_form' => '<html><body>Cool</body></html>',
          'iso_response_code' => 'SP4',
          'method_name' => 'Sale'
        }
      )
    end
  end

  describe '#handle_3ds_response' do
    subject { described_class.new.handle_3ds_response(response) }

    let(:iso_response_code) { '3D0' }
    let(:authentication_status) { 'Y' }
    let(:errors) { nil }
    let(:response) do
      {
        'IsoResponseCode' => iso_response_code,
        'SpiToken' => '12345',
        'ResponseMessage' => 'Cool message',
        'RiskManagement' => {
          'ThreeDSecure' => {
            'AuthenticationStatus' => authentication_status
          }
        },
        'Errors' => errors
      }
    end

    it 'returns an active merchant response' do
      handled_response = subject

      expect(handled_response).to be_a(ActiveMerchant::Billing::Response)
      expect(handled_response.message).to eq('Cool message')
      expect(handled_response.params).to eq(
        {
          'spi_token' => '12345',
          'iso_response_code' => '3D0',
          'three_ds_status' => 'Y',
          'method_name' => '3Ds Response',
          'errors' => nil
        }
      )
    end

    context 'when response code is correct' do
      let(:iso_response_code) { '3D0' }

      context 'when authentication status is Y' do
        let(:authentication_status) { 'Y' }

        it 'returns success' do
          expect(subject.success?).to be true
        end
      end

      context 'when authentication status is A' do
        let(:authentication_status) { 'A' }

        it 'returns success' do
          expect(subject.success?).to be true
        end
      end

      context 'when authentication status is U' do
        let(:authentication_status) { 'U' }

        it 'returns success' do
          expect(subject.success?).to be true
        end
      end

      context 'when authentication status is not correct' do
        let(:authentication_status) { 'Z' }

        it 'returns failure' do
          expect(subject.success?).to be false
        end
      end
    end

    context 'when response code is not correct' do
      let(:iso_response_code) { '00' }
      let(:authentication_status) { 'Y' }
      let(:errors) { [{ 'Boom' => 'Something went wrong' }] }

      it 'returns failures and include errors in response' do
        handled_response = subject

        expect(handled_response.success?).to be false
        expect(handled_response.params).to include({ 'errors' => [{ 'Boom' => 'Something went wrong' }] })
      end
    end
  end

  describe '#payment' do
    let(:spi_token) { '12345' }

    it 'calls FAC payment endpoint with the given spi token and return an active merchant response' do
      stub_request(:post, 'https://staging.ptranz.com/api/spi/payment')
        .with(body: spi_token.to_json)
        .to_return(
          status: 200,
          body: {
            Approved: true,
            ResponseMessage: 'Cool message',
            IsoResponseCode: 'SP4'
          }.to_json
        )

      response = described_class.new.payment(spi_token)
      expect(response).to be_a(ActiveMerchant::Billing::Response)
      expect(response.success?).to be true
      expect(response.message).to eq('Cool message')
      expect(response.params).to eq(
        {
          'iso_response_code' => 'SP4',
          'method_name' => 'Payment'
        }
      )
    end
  end

  describe '#purchase' do
    subject { described_class.new.purchase(nil, nil, { originator: payment }) }
    context 'when payment has spi token' do
      let(:payment) { create(:payment, spi_token: '12345') }

      it 'call payment method' do
        expect_any_instance_of(described_class).to receive(:payment)
        subject
      end
    end

    context 'when payment doesnt have spi token' do
      let(:payment) { create(:payment, spi_token: nil) }

      it 'doesnt call payment method and return an active merchant response with failure' do
        expect_any_instance_of(described_class).not_to receive(:payment)

        response = subject
        expect(response).to be_a(ActiveMerchant::Billing::Response)
        expect(response.success?).to be false
        expect(response.message).to eq('Unable to retrieve Spi Token')
        expect(response.params).to eq({ 'method_name' => 'Payment' })
      end
    end
  end
end
