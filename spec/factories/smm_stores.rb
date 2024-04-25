# frozen_string_literal: true

FactoryBot.define do
  factory :smm_store, class: 'Spree::Store' do
    name { 'Salva Mi Máquina' }
    url { 'www.salvamimaquina.com' }
    default_currency { 'USD' }
    code { 'salvamimaquina' }
    cart_tax_country_iso { 'PA' }
    mail_from_address { 'smm_store@smm.com' }
  end
end
