# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Core::Search::Base do
  describe '#add_simple_scopes' do
    let!(:product) { create(:smm_product) }
    let!(:product2) { create(:smm_product) }
    let!(:price) { create(:price, variant: product.master, amount: 33.33) }
    let!(:price2) { create(:price, variant: product2.master, amount: 33.33) }
    let(:sale_price_calculator) { create(:fixed_amount_sale_price_calculator) }
    let!(:sale_price) { create(:sale_price, enabled: true, value: 22.22, price: price, calculator: sale_price_calculator) }

    it 'includes simple scopes in the search' do
      expect(described_class.new({ scopes: ['on_sale'] }).retrieve_products).to eq([product])
    end

    it 'returns early and dont break if scopes params is missing' do
      expect(described_class.new({}).retrieve_products).to contain_exactly(product, product2)
    end

    it 'doesnt call scope if Spree::Product doesnt respond to it' do
      expect { described_class.new({ scopes: ['wrong_scope'] }).retrieve_products }.not_to raise_error
    end

    it 'raises error if scopes params is not an array' do
      expect { described_class.new({ scopes: :wrong_scope }).retrieve_products }
        .to raise_error(described_class::InvalidOptions, "Invalid option passed to the searcher: 'scopes'")
    end
  end

  describe '#add_search_scopes' do
    let(:option_type) { create(:option_type) }
    let(:option_type2) { create(:option_type) }
    let(:option_value) { create(:option_value, option_type: option_type) }
    let(:option_value2) { create(:option_value, option_type: option_type) }
    let(:option_value3) { create(:option_value, option_type: option_type2) }
    let!(:product) { create(:product, option_types: [option_type]) }
    let!(:product2) { create(:product) }
    let!(:product3) { create(:product) }
    let!(:variant) { create(:variant, product: product, option_values: [option_value]) }
    let!(:variant2) { create(:variant, product: product, option_values: [option_value2]) }
    let!(:variant3) { create(:variant, product: product2, option_values: [option_value3]) }

    it 'parses :with_option scope attributes' do
      expect(described_class.new({ search: { with_option: { option_type.id => [option_value.id] } } }).retrieve_products).to eq([product])
    end
  end
end
