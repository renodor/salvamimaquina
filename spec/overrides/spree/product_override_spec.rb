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

    describe 'on_sale' do
      let!(:product) { create(:smm_product) }
      let!(:product2) { create(:smm_product) }
      let!(:price) { create(:price, variant: product.master, amount: 33.33) }
      let!(:price2) { create(:price, variant: product2.master, amount: 33.33) }
      let(:sale_price_calculator) { create(:fixed_amount_sale_price_calculator) }
      let!(:sale_price) { create(:sale_price, start_at: start_at, end_at: end_at, enabled: true, value: 22.22, price: price, calculator: sale_price_calculator) }

      context 'when sale price has already started and ended' do
        let(:start_at) { Time.now - 2.days }
        let(:end_at) { Time.now - 1.day }

        it 'doesnt return product' do
          expect(described_class.on_sale).to be_empty
        end
      end

      context 'when sale price has already started and doesnt have an end date' do
        let(:start_at) { Time.now - 2.days }
        let(:end_at) { nil }

        it 'returns product' do
          expect(described_class.on_sale).to eq([product])
        end
      end

      context 'when sale price has already started and didnt end yet' do
        let(:start_at) { Time.now - 2.days }
        let(:end_at) { Time.now + 1.day }

        it 'returns product' do
          expect(described_class.on_sale).to eq([product])
        end
      end

      context 'when sale price doesnt have a start date and already ended' do
        let(:start_at) { nil }
        let(:end_at) { Time.now - 1.day }

        it 'doesnt return product' do
          expect(described_class.on_sale).to be_empty
        end
      end

      context 'when sale price doesnt have a start date and doesnt have an end date' do
        let(:start_at) { nil }
        let(:end_at) { nil }

        it 'returns product' do
          expect(described_class.on_sale).to eq([product])
        end
      end

      context 'when sale price doesnt have a start date and didnt end yet' do
        let(:start_at) { nil }
        let(:end_at) { Time.now + 1.day }

        it 'returns product' do
          expect(described_class.on_sale).to eq([product])
        end
      end

      context 'when sale price didnt start yet and doesnt have an end date' do
        let(:start_at) { Time.now + 1.day }
        let(:end_at) { nil }

        it 'doesnt return product' do
          expect(described_class.on_sale).to be_empty
        end
      end

      context 'when sale price didnt start yet and didnt end yet' do
        let(:start_at) { Time.now + 1.day }
        let(:end_at) { Time.now + 2.days }

        it 'doesnt return product' do
          expect(described_class.on_sale).to be_empty
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
      context 'when product is on sale' do
        let!(:product) { create(:smm_product) }
        let!(:price) { create(:price, variant: product.master, amount: 33.33) }
        let(:sale_price_calculator) { create(:fixed_amount_sale_price_calculator) }
        let!(:sale_price) { create(:sale_price, start_at: start_at, end_at: end_at, enabled: true, value: 22.22, price: price, calculator: sale_price_calculator) }

        context 'when sale price has already started and ended' do
          let(:start_at) { Time.now - 2.days }
          let(:end_at) { Time.now - 1.day }

          it 'doesnt return product with price between given values' do
            expect(described_class.price_between(22, 23)).to be_empty
          end
        end

        context 'when sale price has already started and doesnt have an end date' do
          let(:start_at) { Time.now - 2.days }
          let(:end_at) { nil }

          it 'returns product with price between given values' do
            expect(described_class.price_between(22, 23)).to eq([product])
            expect(described_class.price_between(20, 21)).to be_empty
          end
        end

        context 'when sale price has already started and didnt end yet' do
          let(:start_at) { Time.now - 2.days }
          let(:end_at) { Time.now + 1.day }

          it 'returns product with price between given values' do
            expect(described_class.price_between(22, 23)).to eq([product])
            expect(described_class.price_between(20, 21)).to be_empty
          end
        end

        context 'when sale price doesnt have a start date and already ended' do
          let(:start_at) { nil }
          let(:end_at) { Time.now - 1.day }

          it 'doesnt return product with price between given values' do
            expect(described_class.price_between(22, 23)).to be_empty
          end
        end

        context 'when sale price doesnt have a start date and doesnt have an end date' do
          let(:start_at) { nil }
          let(:end_at) { nil }

          it 'returns product with price between given values' do
            expect(described_class.price_between(22, 23)).to eq([product])
            expect(described_class.price_between(20, 21)).to be_empty
          end
        end

        context 'when sale price doesnt have a start date and didnt end yet' do
          let(:start_at) { nil }
          let(:end_at) { Time.now + 1.day }

          it 'returns product with price between given values' do
            expect(described_class.price_between(22, 23)).to eq([product])
            expect(described_class.price_between(20, 21)).to be_empty
          end
        end

        context 'when sale price didnt start yet and doesnt have an end date' do
          let(:start_at) { Time.now + 1.day }
          let(:end_at) { nil }

          it 'doesnt return product with price between given values' do
            expect(described_class.price_between(22, 23)).to be_empty
          end
        end

        context 'when sale price didnt start yet and didnt end yet' do
          let(:start_at) { Time.now + 1.day }
          let(:end_at) { Time.now + 2.days }

          it 'doesnt return product with price between given values' do
            expect(described_class.price_between(22, 23)).to be_empty
          end
        end
      end

      context 'when product is not on sale' do
        let!(:product) { create(:smm_product) }
        let!(:product2) { create(:smm_product) }
        let!(:price) { create(:price, variant: product.master, amount: 33.33) }
        let!(:price2) { create(:price, variant: product.master, amount: 22.22) }

        it 'returns product with price between given values' do
          expect(described_class.price_between(33, 34)).to eq([product])
        end
      end
    end
  end

  describe '#cheapest_variant' do
    let(:product) { create(:smm_product) }

    context 'when product has variants' do
      let(:variant) { create(:variant, product: product) }
      let(:variant2) { create(:variant, product: product) }
      let!(:price) { create(:price, amount: 22.22, variant: variant) }
      let!(:price2) { create(:price, amount: 22.21, variant: variant2) }

      it 'returns variant with the cheapest price' do
        expect(product.cheapest_variant).to eq(variant2)
      end

      it 'takes into account sale price' do
        create(:sale_price, value: 22.20, enabled: true, price: price, calculator: create(:fixed_amount_sale_price_calculator))
        expect(product.cheapest_variant).to eq(variant)
      end
    end

    context 'when product doesnt have variant' do
      it 'returns product master' do
        expect(product.cheapest_variant).to eq(product.master)
      end
    end
  end
end
