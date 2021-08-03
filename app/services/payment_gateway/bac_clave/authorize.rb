# frozen_string_literal: true

module PaymentGateway
  module BacClave
    class Authorize < FirstAtlanticCommerce::Base
      BAC_PUBLIC_KEY = Rails.application.credentials.bac_public_key
      BAC_PRIVATE_KEY = Rails.application.credentials.bac_private_key

      class << self
        def generate_token
          payload = {
            'exp' => (Time.current + 10.hours).to_i,
            'iat' => Time.current.to_i,
            'iss' => '4cxXfxZ4EyLbxYQCa8',
            'unique_name' => '4cxXfxZ4EyLbxYQCa8',
            'sub' => 'SALVAMIMAQUINA',
            'aud' => 'BCO',
            'Request' => {
              'orderId' => 'PANKCSALVAMIMAQUINA-1234567890',
              'totalAmount' => '107',
              'terminalId' => 'TEST0103',
              'invoice' => 'Invoice12345',
              'transactionType' => 'SALE',
              'taxAmount' => '007',
              'clientId' => '111',
              'idSession' => '109282970972098'
            }
          }

          JWT.encode(payload, BAC_PRIVATE_KEY, 'HS256')
        end

        def decode_token(token)
          JWT.decode(token, BAC_PRIVATE_KEY, true, { algorithm: 'HS256' })
        end
      end
    end
  end
end
