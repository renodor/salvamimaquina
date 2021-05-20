# frozen_string_literal: true

module PaymentGateway
  class FirstAtlanticCommerce::Base
    BASE_URL = 'https://marlin.firstatlanticcommerce.com/PGServiceXML'
    ACQUIRER_ID = Rails.application.credentials.fac_acquirer_id
    MERCHANT_ID = Rails.application.credentials.fac_merchant_id
    PASSWORD = Rails.application.credentials.fac_password
    PURCHASE_CURRENCY = 840 # FAC code for USD
  end
end
