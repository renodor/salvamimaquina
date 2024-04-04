# frozen_string_literal: true

FactoryBot.define do
  factory :free_shipping_promotion, class: 'Spree::Promotion' do
    name { 'Entrega Gratis' }
    description { 'free_shipping_threshold' }
    apply_automatically { true }

    after(:create) do |promotion, _evaluator|
      Spree::Promotion::Rules::ItemTotal.create!(
        promotion: promotion,
        preferences: { amount: 150, currency: 'USD', operator: 'gte' }
      )
      Spree::Promotion::Rules::ShippingMethod.create!(promotion: promotion)
      Spree::Promotion::Actions::FreeShipping.create!(promotion: promotion)
    end
  end
end
