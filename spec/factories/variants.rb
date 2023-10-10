# frozen_string_literal: true

FactoryBot.define do
  factory :variant, class: 'Spree::Variant' do
    product

    before(:create) do |variant|
      variant.prices << Spree::Price.new(currency: 'USD', amount: 100.33)
    end
  end
end
