# frozen_string_literal: true

FactoryBot.define do
  factory :smm_shipping_method, class: 'Spree::ShippingMethod' do
    name { 'Panama Zone 1' }

    trait :with_delivery do
      calculator do |shipping_method|
        shipping_method.association(
          :calculator,
          strategy: :build,
          preferred_amount: 3.33,
          type: 'Spree::Calculator::Shipping::CustomShippingCalculator'
        )
      end
    end

    trait :pick_up_in_store do
      calculator do |shipping_method|
        shipping_method.association(
          :calculator,
          strategy: :build,
          preferred_amount: 0,
          type: 'Spree::Calculator::Shipping::FlatPercentItemTotal'
        )
      end
    end
  end
end
