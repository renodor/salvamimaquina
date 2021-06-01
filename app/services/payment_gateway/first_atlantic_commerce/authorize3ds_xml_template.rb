# frozen_string_literal: true

require 'active_support/concern'

module PaymentGateway
  module FirstAtlanticCommerce
    module Authorize3dsXmlTemplate
      extend ActiveSupport::Concern

      # rubocop:disable Metrics/BlockLength, Metrics/MethodLength
      class_methods do
        def build_authorize3ds_xml_payload(
          acquirer_id:,
          merchant_id:,
          order_number:,
          amount:,
          currency_code:,
          signature:,
          card_number:,
          card_expiry_date:,
          card_cvv:
        )
          "<Authorize3DSRequest xmlns:i=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"http://schemas.firstatlanticcommerce.com/gateway/data\">
            <CardDetails>
            <CardCVV2>#{card_cvv}</CardCVV2>
            <CardExpiryDate>#{card_expiry_date}</CardExpiryDate>
            <CardNumber>#{card_number}</CardNumber>
            <Installments>0</Installments>
            </CardDetails>
            <MerchantResponseURL>https://ecm.firstatlanticcommerce.com/FACPGTest/receiveInfo.aspx</MerchantResponseURL>
            <TransactionDetails>
              <AcquirerId>#{acquirer_id}</AcquirerId>
              <Amount>#{amount}</Amount>
              <Currency>#{currency_code}</Currency>
              <CurrencyExponent>2</CurrencyExponent>
              <MerchantId>#{merchant_id}</MerchantId>
              <OrderNumber>#{order_number}</OrderNumber>
              <Signature>#{signature}</Signature>
              <SignatureMethod>SHA1</SignatureMethod>
              <TransactionCode>0</TransactionCode>
              <CustomerReference>This is a test</CustomerReference>
            </TransactionDetails>
          </Authorize3DSRequest>"
        end
      end
      # rubocop:enable Metrics/BlockLength, Metrics/MethodLength
    end
  end
end

