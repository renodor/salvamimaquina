# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Product do
  let(:option_type) { create(:option_type) }
  let(:option_value) { create(:option_value, option_type: option_type) }
  let(:product) { create(:product, purchase_count: 1, available_on: Time.now, option_types: [option_type]) }
  let(:product2) { create(:product, purchase_count: 2, available_on: Time.now + 1.day) }
  let(:product3) { create(:product, purchase_count: 3, available_on: Time.now + 3.day) }
  let(:variant) { create(:variant, product: product, option_values: [option_value]) }
  let(:variant2) { create(:variant, product: product, option_values: [option_value]) }
  let(:price) { create(:price, amount: 56.78, variant: variant) }
  let(:price2) { create(:price, amount: 56.78, variant: variant2) }
  let(:price3) { create(:price, amount: 56.78, variant: product2.master) }
  let(:price4) { create(:price, amount: 56.78, variant: product3.master) }
  let(:calculator) { create(:calculator) }
  let!(:sale_price) { create(:sale_price, enabled: true, value: 12.34, price: price, calculator: calculator) }
  let!(:sale_price2) { create(:sale_price, enabled: true, value: 12.34, price: price2, calculator: calculator) }
  let!(:sale_price3) { create(:sale_price, enabled: true, value: 12.34, price: price3, calculator: calculator) }

  context 'scopes' do
    describe 'ascend_by_purchase_count' do
      it 'sorts products by purchase count in ascending order' do
        expect(described_class.ascend_by_purchase_count).to eq([product, product2, product3])
      end
    end

    describe 'descend_by_purchase_count' do
      it 'sorts products by purchase count in descending order' do
        expect(described_class.descend_by_purchase_count).to eq([product3, product2, product])
      end
    end

    describe 'ascend_by_available_on' do
      it 'sorts products by available on date in ascending order' do
        expect(described_class.ascend_by_available_on).to eq([product, product2, product3])
      end
    end

    describe 'descend_by_available_on' do
      it 'sorts products by available on date in descending order' do
        expect(described_class.descend_by_available_on).to eq([product3, product2, product])
      end
    end

    describe 'on_sale' do
      it 'only returns discounted products' do
        expect(described_class.on_sale).to contain_exactly(product, product2)
      end
    end

    describe 'with_option' do
      it 'returns products with de given option type and value' do
        expect(described_class.with_option(option_type.id, [option_value.id])).to eq([product])
      end
    end
  end
end
