# frozen_string_literal: true

require 'active_support/concern'

module PaymentGateway
  module FirstAtlanticCommerce
    module AuthorizeXmlTemplate
      extend ActiveSupport::Concern

      # rubocop:disable Metrics/BlockLength
      # rubocop:disable Metrics/MethodLength
      class_methods do
        def build_authorize_xml_payload(
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
          "<AuthorizeRequest xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"http://schemas.firstatlanticcommerce.com/gateway/data\">
            <TransactionDetails>
              <AcquirerId>#{acquirer_id}</AcquirerId>
              <MerchantId>#{merchant_id}</MerchantId>
              <OrderNumber>#{order_number}</OrderNumber> <!-- We define it -->
              <TransactionCode>0</TransactionCode>
              <Amount>#{amount}</Amount> <!-- Always 12 characters. Ex: $12 would be 000000001200-->
              <Currency>#{currency_code}</Currency>
              <CurrencyExponent>2</CurrencyExponent> <!-- Number of digits after the colon (decimals) -->
              <SignatureMethod>SHA1</SignatureMethod>
              <Signature>#{signature}</Signature>
              <IPAddress />
              <CustomData />
              <CustomerReference />
              <ExtensionData />
            </TransactionDetails>
            <CardDetails>
              <CardNumber>#{card_number}</CardNumber>
              <CardExpiryDate>#{card_expiry_date}</CardExpiryDate>
              <CardCVV2>#{card_cvv}</CardCVV2>
              <IssueNumber />
              <StartDate />
              <Installments>0</Installments>
              <DocumentNumber />
              <ExtensionData />
            </CardDetails>
            <BillingDetails>
              <BillToAddress>STREET786</BillToAddress>
              <BillToAddress2 />
              <BillToZipPostCode />
              <BillToFirstName />
              <BillToLastName />
              <BillToCity>BELGARDE</BillToCity>
              <BillToState />
              <BillToCountry />
              <BillToEmail />
              <BillToTelephone>875684445</BillToTelephone>
              <BillToCounty />
              <BillToMobile />
              <ExtensionData />
            </BillingDetails>
            <ThreeDSecureDetails>
              <ECIIndicator />
              <AuthenticationResult />
              <TransactionStain />
              <CAVV />
            </ThreeDSecureDetails>
            <RecurringDetails>
              <IsRecurring>false</IsRecurring>
              <ExecutionDate />
              <Frequency />
              <NumberOfRecurrences>0</NumberOfRecurrences>
            </RecurringDetails>
              <ShippingDetails>
              <ShipToAddress />
              <ShipToAddress2 />
              <ShipToZipPostCode />
              <ShipToFirstName />
              <ShipToLastName />
              <ShipToCity />
              <ShipToState />
              <ShipToCountry />
              <ShipToEmail />
              <ShipToTelephone />
              <ShipToMobile />
              <ShipToCounty />
            </ShippingDetails>
            <FraudDetails>
              <SessionId />
              <AuthResponseCode />
              <AVSResponseCode />
              <CVVResponseCode />
            </FraudDetails>
            <InterfaceCode></InterfaceCode>
            <TransactionID>00000000-0000-0000-0000-000000000000</TransactionID>
            <Version>0</Version>
            <ExtensionData />
          </AuthorizeRequest>"
        end
      end
      # rubocop:enable Metrics/BlockLength
      # rubocop:enable Metrics/MethodLength
    end
  end
end