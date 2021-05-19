module PaiementGateway
  module FirstAtlanticCommerce
    module AuthorizeXmlTemplate
      def build_authorize_xml_payload(acquirer_id:, merchant_id:, order_number:, amount:,)
        "<AuthorizeRequest xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"http://schemas.firstatlanticcommerce.com/gateway/data\">
          <TransactionDetails>
            <AcquirerId>#{acquirer_id}</AcquirerId>
            <MerchantId>#{merchant_id}</MerchantId>
            <OrderNumber>#{order_number}</OrderNumber> <!-- We define it -->
            <TransactionCode>0</TransactionCode>
            <Amount>#{amount}</Amount> <!-- Always 12 characters. Ex: $12 would be 000000001200-->
            <Currency>840</Currency>
            <CurrencyExponent>2</CurrencyExponent> <!-- Number of digits after the colon (decimals) -->
            <SignatureMethod>SHA1</SignatureMethod>
            <Signature>0O+2adPDppKHQM89y5Xq2DgYcQs=</Signature>
            <IPAddress />
            <CustomData />
            <CustomerReference />
            <ExtensionData />
          </TransactionDetails>
          <CardDetails>
            <CardNumber>4111111111111111</CardNumber>
            <CardExpiryDate>0130</CardExpiryDate>
            <CardCVV2>123</CardCVV2>
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
  end
end