# frozen_string_literal: true

FactoryBot.define do
  factory :smm_stock_location, class: 'Spree::StockLocation' do
    name { 'Stock Location' }

    trait :san_francisco do
      name { 'San Francisco' }
      repair_shopr_id { 1927 }
    end

    trait :bella_vista do
      name { 'Bella Vista' }
      repair_shopr_id { 1928 }
    end
  end
end
