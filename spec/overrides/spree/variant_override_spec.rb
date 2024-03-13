# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Variant do
  describe 'has many prices relation' do
    let!(:price) { create(:price, amount: 130.22, created_at: Time.now) }
    let!(:price2) { create(:price, amount: 333, created_at: Time.now - 1.day) }
    let!(:price3) { create(:price, amount: 130.22, created_at: Time.now + 1.day) }
    let!(:variant) { create(:smm_variant, prices: [price, price3, price2]) }

    it 'orders prices by created_at' do
      expect(variant.reload.prices).to eq([price3, price, price2])
    end
  end

  context 'repair shopr id uniqueness validation' do
    let!(:variant) { create(:variant, repair_shopr_id: 123) }
    let!(:variant2) { create(:variant, repair_shopr_id: nil) }
    let(:variant3) { build(:variant, repair_shopr_id: 123) }
    let(:variant4) { build(:variant, repair_shopr_id: nil) }

    it 'validates uniqueness of repair_shopr_id for non deleted record allowing nil value' do
      expect(variant3.valid?).to be false
      expect(variant3.errors.messages).to eq({ repair_shopr_id: ['ya ha sido tomado'] })

      expect(variant4.valid?).to be true

      variant.destroy!
      expect(variant3.valid?).to be true
    end
  end

  it 'has a condition enum' do
    expect(described_class.conditions).to eq({ 'original' => 0, 'refurbished' => 1 })
  end

  describe '#destroy_and_destroy_product_if_no_other_variants!' do
    context 'when product has other variants' do
      let(:product) { create(:smm_product) }
      let!(:variant) { create(:variant, product: product) }
      let!(:variant2) { create(:variant, product: product) }

      it 'destroy variant but not product' do
        variant.destroy_and_destroy_product_if_no_other_variants!

        expect { variant.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect(product.reload.deleted_at).to be nil
      end
    end

    context 'when product doesnt have any other variant' do
      let(:product) { create(:smm_product) }
      let!(:variant) { create(:variant, product: product) }

      it 'destroy variant and product' do
        variant.destroy_and_destroy_product_if_no_other_variants!

        expect { variant.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect { product.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '#options_text' do
    let(:option_type) { create(:option_type, name: 'color', presentation: 'color') }
    let(:option_type2) { create(:option_type, name: 'capacity', presentation: 'capacity') }
    let(:option_type3) { create(:option_type, name: 'model', presentation: 'model') }
    let(:option_value) { create(:option_value, name: 'Green', presentation: 'Green', option_type: option_type) }
    let(:option_value2) { create(:option_value, name: '256gb', presentation: '256gb', option_type: option_type2) }
    let(:option_value3) { create(:option_value, name: 'iPhone', presentation: 'iPhone', option_type: option_type3) }
    let(:product) { create(:smm_product, option_types: [option_type, option_type2]) }
    let!(:variant) { create(:variant, product: product, option_values: [option_value, option_value2, option_value3]) }

    it 'returns a text of variant options without option type and without model by default' do
      expect(variant.options_text).to eq('Green, 256gb')
    end

    it 'returns a text of variant options with translated option types when show_option_type is true' do
      expect(variant.options_text(show_option_type: true))
        .to eq('Color: Green, Capacidad: 256gb')
    end

    it 'returns a text of variant options including model if show_model is true' do
      expect(variant.options_text(show_option_type: true, show_model: true))
        .to eq('Color: Green, Capacidad: 256gb, Modelo: Iphone')
    end
  end

  describe '#price' do
    let!(:price) { create(:price, amount: 130.22) }
    let!(:price2) { create(:price, amount: 333, created_at: Time.now - 1.day) }
    let!(:price3) { create(:price, amount: 130.22) }
    let!(:calculator) { create(:fixed_amount_sale_price_calculator) }
    let!(:sale_price) { create(:sale_price, value: 122.22, enabled: true, price: price3, calculator: calculator) }
    let!(:variant) { create(:smm_variant, prices: [price, price2]) }
    let!(:variant2) { create(:smm_variant, prices: [price3]) }

    it 'returns variant latest price or sale price amount' do
      expect(variant.price).to eq(130.22)
      expect(variant2.price).to eq(122.22)
    end
  end

  describe '#price=' do
    context 'when variant is already created' do
      let!(:price) { create(:price, amount: 123.45) }
      let!(:variant) { create(:variant, prices: [price]) }

      it 'sets new price to variant' do
        expect { variant.price = 222.22 }.not_to change(Spree::Price, :count)
        expect(variant.reload.price).to eq(222.22)
      end
    end

    context 'when variant is not created yet' do
      let(:variant) { build(:smm_variant) }

      it 'sets new price to variant and persists it when variant is saved' do
        expect(variant.price).to be nil

        variant.price = 123.45
        variant.save!

        expect(variant.reload.price).to eq(123.45)
      end
    end
  end

  describe '#on_sale?' do
    let!(:price) { create(:price) }
    let!(:price2) { create(:price) }
    let!(:price3) { create(:price) }
    let!(:calculator) { create(:fixed_amount_sale_price_calculator) }
    let!(:calculator2) { create(:fixed_amount_sale_price_calculator) }
    let!(:sale_price) { create(:sale_price, value: 122.22, enabled: true, start_at: Time.now + 1.day, price: price2, calculator: calculator) }
    let!(:sale_price2) { create(:sale_price, value: 122.22, enabled: true, price: price3, calculator: calculator2) }
    let!(:variant) { create(:smm_variant, prices: [price]) }
    let!(:variant2) { create(:smm_variant, prices: [price2]) }
    let!(:variant3) { create(:smm_variant, prices: [price3]) }

    it 'returns true when variant as an active sale price and false when not' do
      expect(variant.on_sale?).to be false
      expect(variant2.on_sale?).to be false
      expect(variant3.on_sale?).to be true
    end
  end

  describe '#original_price' do
    let!(:price) { create(:price, amount: 130.22) }
    let!(:price2) { create(:price, amount: 130.22) }
    let!(:calculator) { create(:fixed_amount_sale_price_calculator) }
    let!(:sale_price) { create(:sale_price, value: 122.22, enabled: true, price: price2, calculator: calculator) }
    let!(:variant) { create(:variant, prices: [price]) }
    let!(:variant2) { create(:variant, prices: [price2]) }

    it 'returns variant original price even when variant is on sale' do
      expect(variant.original_price).to eq(130.22)
      expect(variant2.original_price).to eq(130.22)
    end
  end

  describe '#can_supply?' do
    let(:variant) { create(:variant) }
    let(:stock_item) { create(:stock_item, variant: variant) }
    let(:stock_item2) { create(:stock_item, variant: variant) }

    it 'returns true when variant has at least the given quantity in stock' do
      stock_item.set_count_on_hand(1)
      stock_item2.set_count_on_hand(1)

      expect(variant.can_supply?).to be true
      expect(variant.can_supply?(2)).to be true
      expect(variant.can_supply?(3)).to be false
    end
  end
end
