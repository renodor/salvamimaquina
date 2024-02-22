# frozen_string_literal: true

FactoryBot.define do
  factory :sale_price, class: 'Spree::SalePrice' do
    price
  end
end
