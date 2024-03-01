# frozen_string_literal: true

FactoryBot.define do
  factory :fixed_amount_sale_price_calculator, class: 'Spree::Calculator::FixedAmountSalePriceCalculator' do
    # type { 'Spree::Calculator::FixedAmountSalePriceCalculator' }
    # calculable_type { 'Spree::SalePrice' }
  end
end
