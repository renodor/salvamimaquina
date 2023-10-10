# frozen_string_literal: true

FactoryBot.define do
  factory :product, class: 'Spree::Product' do
    transient do
      master_repair_shopr_id { nil }
      san_francisco_stock { 10 }
      bella_vista_stock { 5 }
    end

    sequence(:name) { |n| "Cool Product ##{n}" }
    description { 'Cool product description' }
    available_on { Date.today }

    before(:create) do |product, evaluator|
      product.shipping_category = Spree::ShippingCategory.find_or_create_by!(name: 'Default')
      product.master.prices << Spree::Price.new(currency: 'USD', amount: 100.33)
      product.master.repair_shopr_id = evaluator.master_repair_shopr_id.presence
    end

    after(:create) do |product, evaluator|
      Spree::StockLocation.find_or_create_by!(name: 'San Francisco').stock_items.find_by(variant_id: product.master.id).set_count_on_hand(evaluator.san_francisco_stock)
      Spree::StockLocation.find_or_create_by!(name: 'Bella Vista').stock_items.find_by(variant_id: product.master.id).set_count_on_hand(evaluator.bella_vista_stock)
    end
  end
end
