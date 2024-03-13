# frozen_string_literal: true

FactoryBot.define do
  factory :smm_variant, class: 'Spree::Variant' do
    product
  end
end
