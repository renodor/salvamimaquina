# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Product do
  context 'scopes' do
    context 'ordering scopes' do
      let!(:product) { create(:product, purchase_count: 1, price: 123.45, available_on: Time.now) }
      let!(:product2) { create(:product, purchase_count: 2, available_on: Time.now + 1.day) }
      let!(:product3) { create(:product, purchase_count: 3, available_on: Time.now + 3.day) }

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
    end

    describe 'with_option' do
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

      it 'returns products variants with de given option type and value' do
        expect(described_class.with_option(option_type.id, [option_value.id])).to eq([product])
      end
    end

    describe 'with_taxon' do
      let(:taxon) { create(:taxon, name: 'Cool taxon') }
      let(:taxon2) { create(:taxon, name: 'Cool taxon2', parent_id: taxon.id) }
      let(:taxon3) { create(:taxon) }
      let!(:product) { create(:product, taxons: [taxon]) }
      let!(:product2) { create(:product, taxons: [taxon2]) }
      let!(:product3) { create(:product, taxons: [taxon3]) }

      before do
        # Needed otherwise awesome_nested_set gem doesn't work well with FactoryBot and don't assign properly lft and rgt values
        # https://github.com/collectiveidea/awesome_nested_set/issues/10
        taxon.reload
        taxon2.reload
        taxon3.reload
      end

      it 'returns products in the given taxon and its descendents' do
        expect(described_class.in_taxon(taxon)).to contain_exactly(product, product2)
      end
    end

    describe 'price_between' do
      let!(:product) { create(:smm_product) }
      let!(:product2) { create(:smm_product) }
      let!(:price) { create(:price, variant: product.master, amount: 33.33) }
      let!(:price2) { create(:price, variant: product.master, amount: 22.22) }

      it 'returns product with price between given values' do
        expect(described_class.price_between(33, 34)).to eq([product])
      end
    end
  end

  describe '#cheapest_variant' do
    let(:product) { create(:smm_product) }

    context 'when product has variants' do
      let(:price) { create(:price, amount: 22.22) }
      let(:price2) { create(:price, amount: 22.21) }
      let!(:variant) { create(:smm_variant, product: product, prices: [price]) }
      let!(:variant2) { create(:smm_variant, product: product, prices: [price2]) }

      it 'returns variant with the cheapest price' do
        expect(product.cheapest_variant).to eq(variant2)
      end
    end

    context 'when product doesnt have variant' do
      it 'returns product master' do
        expect(product.cheapest_variant).to eq(product.master)
      end
    end
  end
end
