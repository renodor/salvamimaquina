# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Order do
  let!(:bella_vista_stock_location) { create(:stock_location, name: 'Bella Vista') }
  let!(:san_francisco_stock_location) { create(:stock_location, name: 'San Francisco') }
  let(:variant) { create(:variant) }
  let(:variant2) { create(:variant) }
  let(:order) { create(:order, total: 123.45) }
  let(:order2) { create(:order, total: 0) }

  it 'doesnt have confirm checkout step' do
    expect(order.checkout_steps).to contain_exactly('address', 'delivery', 'complete', 'payment')
  end

  describe '#process_payments_before_complete' do
    it 'returns early if payment is not required' do
      expect(order2.process_payments_before_complete).to be nil
    end

    it 'returns true if payment is correctly processed' do
      allow(order).to receive(:process_payments!).and_return true
      expect(order.process_payments_before_complete).to be true
    end

    it 'returns true if payment is correctly processed' do
      allow(order).to receive(:process_payments!).and_return false
      expect(order.process_payments_before_complete).to be false
    end
  end

  describe '#find_stock_location' do
    context 'when order shipments have line items with different quantities' do
      let!(:line_item) { create(:line_item, variant: variant, quantity: 1, order: order) }
      let!(:line_item2) { create(:line_item, variant: variant2, quantity: 2, order: order) }

      it 'returns the stock location of the shipment with line items with more quantity' do
        variant.stock_items.find_by(stock_location: bella_vista_stock_location).set_count_on_hand(10)
        variant2.stock_items.find_by(stock_location: san_francisco_stock_location).set_count_on_hand(5)
        order.create_proposed_shipments
        expect(order.find_stock_location).to eq(san_francisco_stock_location)
      end
    end

    context 'when order shipments have line items with equal quantity' do
      let!(:line_item) { create(:line_item, variant: variant, quantity: 2, order: order) }
      let!(:line_item2) { create(:line_item, variant: variant2, quantity: 2, order: order) }

      it 'returns Bella Vista stock location if shipments have line items with the same quantity' do
        variant.stock_items.find_by(stock_location: bella_vista_stock_location).set_count_on_hand(10)
        variant2.stock_items.find_by(stock_location: san_francisco_stock_location).set_count_on_hand(5)
        order.create_proposed_shipments
        expect(order.find_stock_location).to eq(bella_vista_stock_location)
      end
    end
  end
end
