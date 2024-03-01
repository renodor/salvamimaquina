# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Order do
  let(:price) { create(:price, amount: 56.78) }
  let(:price2) { create(:price, amount: 56.78) }
  let(:calculator) { create(:fixed_amount_sale_price_calculator) }
  let!(:sale_price) { create(:sale_price, enabled: true, value: 12.34, price: price, calculator: calculator) }
  let!(:sale_price2) { create(:sale_price, enabled: false, value: 11.34, price: price, calculator: calculator) }
  let!(:sale_price3) { create(:sale_price, enabled: true, start_at: Time.now + 1.day, value: 10.34, price: price, calculator: calculator) }

  it 'has many active sales prices' do
    expect(price.active_sale_prices).to eq([sale_price])
  end

  describe '#price' do
    it 'returns first active sale price when present' do
      expect(price.price).to eq(12.34)
    end

    it 'returns price amount when no active sale prices are present' do
      expect(price2.price).to eq(56.78)
    end
  end
end
