# frozen_string_literal: true

FactoryBot.define do
  factory :shipping_category, class: 'Spree::ShippingCategory' do
    name { 'Shipping Category' }

    trait :default do
      name { 'Default' }
    end
  end
end
